require "uri"

module Schematrix
  # The JSON Schema type names the compiler tracks, shared by the
  # visitor and the notation hooks. TYPE_BOTTOM is not a schema type
  # name: it marks the "false" schema (no valid instance) and maps
  # to each notation's bottom type.
  TYPE_ARRAY = "array"
  TYPE_BOOLEAN = "boolean"
  TYPE_INTEGER = "integer"
  TYPE_NULL = "null"
  TYPE_NUMBER = "number"
  TYPE_OBJECT = "object"
  TYPE_STRING = "string"

  # Pseudo type marking the "false" schema (no valid instance). Not a
  # JSON Schema type name: templates map it to their bottom type.
  TYPE_BOTTOM = "bottom"

  # The compiled record for one schema node. This is the internal
  # representation the generators render; Schematrix.generate returns
  # these, keyed by locator.
  #
  # - `type`: set of JSON Schema type names (the TYPE_ constants).
  # - `ref`: locator of the referenced object schema, when the node
  #   resolved to a `$ref` the compiler kept; nil otherwise.
  # - `properties`: hash of original property name => Schema.
  # - `required`: whether the node demands a value (a property the
  #   constructor demands); nil on records that say nothing about it.
  # - `additional_properties`: Schema of the catch-all, Schema::Empty
  #   for the open default, nil when the shape is closed.
  # - `items`: Schema of the array element.
  # - `prefix_items`: array of Schemas, one per tuple position.
  # - `any_of` / `one_of`: arrays of variant Schemas (value context
  #   only; object context merges its branches instead).
  # - `intersection`: true when the record conjoins (an `allOf` merge);
  #   its terms intersect instead of union.
  # - `default`: the schema's `default` value.
  # - `description`, `title`, `enum`: captured annotations. The
  #   description becomes the generated class comment.
  # - `format`: the schema's `format` annotation. Scalar slots read it
  #   against the scalar type table to render a formatted Ruby type
  #   and to find the coercer that converts on load and dump.
  Schema =
    Data.define(
      :additional_properties,
      :any_of,
      :default,
      :description,
      :enum,
      :format,
      :intersection,
      :items,
      :one_of,
      :prefix_items,
      :properties,
      :ref,
      :required,
      :title,
      :type,
    )

  # The unconstrained record: no types, no ref, no variants. It types
  # as untyped and is the identity for intersections.
  Schema::Empty =
    Schema.new(
      additional_properties: nil,
      any_of: [].freeze,
      default: nil,
      enum: nil,
      format: nil,
      intersection: false,
      items: nil,
      one_of: [].freeze,
      prefix_items: [].freeze,
      properties: nil,
      description: nil,
      ref: nil,
      required: nil,
      title: nil,
      # Frozen because this record is shared process-wide: a
      # mutation anywhere would corrupt every later compilation.
      type: Set.new.freeze,
    )

  # The "false" schema accepts no instance at all. It types as a
  # bottom type where the target language has one (T.noreturn in
  # Sorbet), untyped elsewhere.
  Schema::Bottom = Schema::Empty.with(type: Set[TYPE_BOTTOM].freeze)

  # The mergeable shape of an object schema: its own properties and
  # its normalized additionalProperties schema. The fold algebra
  # (allOf conjoins, anyOf/oneOf/then/else unions) composes these.
  Body = Data.define(:properties, :additional_properties)

  # Predicates shared by the compiler and the generators: what a
  # compiled schema constrains, and whether the constructor demands
  # the property.
  class Schema
    # Whether the schema constrains nothing: empty type set, no ref,
    # no variants. It types as untyped and is the identity for
    # intersections.
    def untyped?
      type.empty? && ref.nil? && any_of.empty? && one_of.empty?
    end

    # Whether the constructor demands the property: listed in
    # required, with no default to fall back on. A null-typed
    # property still demands the keyword (its value may be nil; the
    # argument may not be omitted), so only this predicate decides
    # the constructor signature and everything that must match it.
    def constructor_required?
      return false unless required
      return false unless default.nil?

      true
    end

    # Whether the constructor demands the property and its type does
    # not admit nil: optional values render nilable wherever they may
    # be absent.
    def strictly_required?
      return false if type.include?(TYPE_NULL)

      constructor_required?
    end

    # Whether the schema's whole shape is a catch-all (an object with
    # no own properties, no ref, no variants, and a non-closed
    # additionalProperties). Such a schema is a plain Hash, not a
    # class: it types as Hash[String, <catch-all value type>] and
    # generates nothing, because a class would only wrap a map and
    # could not be iterated. A closed shape (catch-all nil) is an
    # empty object, not a map, and keeps its class.
    def map_shaped?
      return false unless type.include?(TYPE_OBJECT)
      return false unless (type - [TYPE_OBJECT, TYPE_NULL]).empty?
      return false unless ref.nil?
      return false if intersection
      return false unless any_of.empty? && one_of.empty?
      return false if additional_properties.nil?

      properties.nil? || properties.empty?
    end
  end

  # Visits a single schema subtree rooted at the given locator. When it
  # finds a $ref it resolves the reference through the document store
  # to decide how to represent it, and records edges to object schemas
  # so their classes get generated. It never visits ref targets itself:
  # the caller (see Compiler) decides when and whether to do that.
  #
  # Nodes are consumed as instances of the metaschema model
  # (Schematrix::Meta::Schema): compile converts raw store documents at
  # its boundary, so reads are typed throughout. The $ref rewrite
  # algebra (except/merge in resolve_reference) stays on raw
  # String-keyed hashes: to_h dumps a node, the algebra merges, and
  # from_h loads the result back (see present_slots).
  #
  # Positions inside the document are threaded down as explicit path
  # segments (leading empty segment for the document root, e.g.
  # ["", "properties", "tags"]); every locator the visitor derives is a
  # pure function of that path.
  class Visitor
    # Keywords without a codegen representation. They are ignored
    # and logged once per document at debug level; the shapes stay
    # open. Extend the list when the official metaschemas reveal
    # more keywords without a rendering as Ruby types.
    IGNORED_KEYWORDS = %w[
      not
      unevaluatedProperties
      unevaluatedItems
      contains
      minContains
      maxContains
      dependentRequired
    ].freeze

    # Sibling keywords beside a $ref that change the compiled shape.
    # When any of these appears next to a $ref the node applies both
    # (2020-12), so it rewrites into its allOf-equivalent; everything
    # else beside a $ref (annotations, scalar constraints without
    # codegen) leaves the reference on the pure-ref path.
    SHAPE_SIBLINGS = %w[
      type
      const
      properties
      required
      additionalProperties
      items
      prefixItems
      allOf
      anyOf
      oneOf
      then
      else
      dependentSchemas
    ].freeze

    # The model materializes the metaschema's constructor defaults for
    # keys a document left absent (properties: {}, required: [], ...).
    # to_h of a fresh instance is exactly that default set.
    MODEL_DEFAULTS = Schematrix::Meta::Schema.new.to_h.freeze

    # The findings of a visit: `objects` maps the locator of every
    # object schema the subtree contains to its Schema record, and
    # `edges` lists the locators of object schemas living elsewhere
    # that it references. The Compiler feeds the edges back into its
    # worklist so those classes get generated too.
    attr_reader :objects, :edges

    # `locator` is the URI this visitor's subtree is rooted at, and
    # `store` the shared DocumentStore. `closed_shapes` treats an
    # absent additionalProperties as false (closed classes) instead
    # of the spec's open default.
    def initialize(locator, store, closed_shapes: false)
      @locator = locator
      @store = store
      @closed_shapes = closed_shapes
      @objects = {}
      @edges = []
      @ref_base = nil
    end

    # Compiles the subtree rooted at this visitor's locator. `node` is
    # the raw parsed document node there: a Hash or a boolean. Returns
    # self; read objects and edges afterwards.
    def compile(node)
      # Seed the path from the locator's fragment: a visitor may start
      # at the document root ("/" seeds the nameless [""] site) or at
      # an interior locator the compiler discovered through an edge.
      # The store hands out raw parsed documents; the model boundary
      # conversion happens here.
      node = Schematrix::Meta::Schema.from_h(node) if node.is_a?(Hash)
      path = @locator.fragment.split("/")
      name = path.pop || "" # document root is nameless
      visit_schema(path, name, node, required: false)

      self
    end

    private

    # The document's own keys, as a String-keyed hash: the node's
    # to_h with the slots the document left absent (which from_h
    # filled with the metaschema's defaults) stripped again. A key
    # explicitly carrying exactly its default value is
    # indistinguishable from an absent one and stays stripped; both
    # spellings compile identically. This is what the $ref rewrite
    # algebra merges with.
    def present_slots(node)
      node.to_h.reject { |key, value| value == MODEL_DEFAULTS[key] }
    end

    # Compiles the schema at `path + [name]`. The path segments name
    # the containing chain (properties, $defs, anyOf_0, ...); an
    # empty name is the document root.
    def visit_schema(path, name, node, required: true, register_object: true)
      site = path + [name]

      # JSON Schema allows "true" as a catch-all. It types as
      # untyped and creates no class: a class would force object
      # shape on values that may be scalars, so no slot type may ever
      # point at one. A document that is just true produces no output.
      return Schema::Empty if node.is_a?(TrueClass)

      # JSON Schema "false" accepts nothing: no class, bottom type
      return Schema::Bottom if node.is_a?(FalseClass)

      node, ref, inline_base = resolve_reference(site, node)
      # A reference that resolved to the "false" schema accepts
      # nothing whichever siblings it had: the node is uninhabitable
      return Schema::Bottom if node.is_a?(FalseClass)

      # Content inlined from another document compiles against that
      # document, so refs nested inside it resolve where they were
      # written (see resolve_reference).
      schema = nil
      with_ref_base(inline_base) do
        IGNORED_KEYWORDS.each { |keyword| ignore_keyword(site, node, keyword) }

        type = Set.new(Array(node.type))
        # a const with no declared type infers from the value's
        # Ruby class; values that do not map cleanly fall back to
        # untyped. A const of explicit null is indistinguishable
        # from an absent const on the model and stays untyped
        # (over-accepting).
        if type.empty? && !node.const.nil?
          inferred = const_type(node.const)
          type = Set[inferred] unless inferred.nil?
        end
        # an enum with no declared type infers the union of its
        # values' clean classes, same rule as const; values that do
        # not map cleanly contribute nothing (their alternatives'
        # types still cover the enumerated scalars, over-accepting)
        if type.empty? && !node.enum.nil?
          inferred = node.enum.filter_map { |value| const_type(value) }.uniq
          type = Set[*inferred] unless inferred.empty?
        end
        enum = node.enum
        default = node.default
        title = node.title
        description = node.description
        format = node.format
        items = visit_subtree(site, "items", node.items)
        prefix_items = visit_prefix_items(site, node)

        # Composition context: a node that is the document root or
        # types as object becomes a generated class, so composition
        # branches merge into one property set. A value node
        # unions its anyOf/oneOf branches as variants instead, except
        # that inline object branches inside anyOf merge into the
        # property's own class.
        object_context = name.empty? || type.include?(TYPE_OBJECT)
        if object_context
          body = compile_object(site, node)
          properties = body.properties
          additional_properties = body.additional_properties
          any_of = []
          one_of = []
        else
          branches = split_value_branches(node)
          any_of = visit_variant_list(site, "anyOf", branches[:any_of])
          one_of = visit_variant_list(site, "oneOf", branches[:one_of])
          if branches[:mergeable].any?
            # anyOf object branches merge into one class that
            # registers at this node's own locator
            body = merge_value_branches(site, node, branches[:mergeable])
            properties = body.properties
            additional_properties = body.additional_properties
            type |= Set[TYPE_OBJECT]
          else
            properties = compile_properties(site, node)
            additional_properties = visit_additional_properties(site, node)
          end
        end

        schema =
          Schema.new(
            additional_properties:,
            any_of:,
            default:,
            description:,
            enum:,
            format:,
            intersection: false,
            items:,
            one_of:,
            prefix_items:,
            properties:,
            ref:,
            required:,
            title:,
            type:,
          )

        # Value-context allOf: the branches conjoin into the slot's
        # record (object context folded them in compile_object
        # instead).
        unless object_context
          schema = fold_value_allof(site, schema, node.all_of)
        end

        own_class = ref.nil? && schema.type.include?(TYPE_OBJECT)
        if register_object && own_class && !schema.map_shaped?
          @objects[current_locator(site)] = schema
        end
      end

      schema
    end

    # Notes a keyword without codegen representation on the
    # document's registry; the store logs it the first time it is
    # seen in this document. Presence reads through the model: a
    # keyword the document never wrote stays absent after the
    # default-stripping of present_slots.
    def ignore_keyword(site, node, keyword)
      return unless present_slots(node).key?(keyword)

      # ref_base, not @locator: content inlined from another document
      # belongs to that document (see with_ref_base)
      @store.note_ignored(
        @store.document_key(ref_base),
        keyword,
        current_locator(site),
      )
    end

    # Resolves a $ref, if present, by following the chain of references
    # to its final target node (targets come back raw from the store;
    # the rewrite algebra merges raw hashes and from_h loads the
    # result back into the model):
    # - object target: keep the node as-is and return the target's locator
    #   as ref, recording the edge so its class is generated; shape-
    #   applying siblings rewrite the node into the allOf-equivalent
    #   instead (2020-12 semantics, see resolve_reference).
    # - scalar target: return the target node itself so its type
    #   information is compiled in place of the reference, and no ref.
    # A $dynamicRef resolves through the static approximation first.
    def resolve_reference(site, node)
      reference = node.ref
      if reference.nil? && node.dynamic_ref
        dynamic_ref = node.dynamic_ref
        reference = dynamic_anchor_locator(site, dynamic_ref)
        if reference.nil?
          Schematrix.logger&.debug(
            "Unresolvable $dynamicRef #{dynamic_ref} at " \
              "#{current_locator(site)}",
          )
          return node, nil, nil
        end
      end
      return node, nil, nil if reference.nil?

      target, locator = final_target(ref_base, reference)
      return node, nil, nil if target.nil?

      unless target.is_a?(Hash)
        # Boolean targets: "true" accepts anything, so only the
        # reference's own siblings remain (an empty node when the $ref
        # stood alone, which types as untyped, same as "true");
        # "false" accepts nothing, and visit_schema compiles the whole
        # node to the bottom schema after resolution.
        if target == true
          return Schematrix::Meta::Schema.from_h(siblings_of(node)), nil, nil
        end

        return target, nil, nil
      end

      if Array(target["type"]).include?(TYPE_OBJECT)
        # 2020-12 semantics: a $ref applies alongside its siblings, so
        # a ref with shape-applying siblings is the allOf-equivalent
        # of the target and those siblings. Rewrite the node into
        # that form instead of keeping the ref: the site becomes its
        # own conjoined class, no dead sibling classes
        # register, and no dangling class references render.
        # Annotation-only siblings (title, description, default, ...)
        # and scalar constraints without codegen stay on the pure-ref
        # path, where the edge and the target's class remain.
        siblings = siblings_of(node)
        if SHAPE_SIBLINGS.any? { |keyword| siblings.key?(keyword) }
          rewritten =
            siblings.merge(
              "type" => Array(siblings["type"]) | [TYPE_OBJECT],
              "allOf" => [{ "$ref" => reference }, *Array(siblings["allOf"])],
            )
          return Schematrix::Meta::Schema.from_h(rewritten), nil, nil
        end

        # A target whose whole shape is a catch-all is a plain
        # Hash, not a class. Inline its content at this site (the
        # slot's own record is then map-shaped and renders as a Hash)
        # so no class is generated for the target and no edge is
        # recorded; the local siblings win over the target, as on the
        # scalar inline path.
        if map_target?(target)
          base = document_base(locator)
          base = nil if same_document?(base, ref_base)
          return inline_model(target, node), nil, base
        end

        @edges << locator
        [with_ref_types(node, target), locator, nil]
      else
        # Inline the target's keywords, local siblings win over
        # them. Returns the target's document as the base for the
        # rest of the visit when it differs from the current one, so
        # refs nested inside the inlined content resolve against
        # their own document.
        base = document_base(locator)
        base = nil if same_document?(base, ref_base)
        [inline_model(target, node), nil, base]
      end
    end

    # The node's own keys beside the reference, ready for the raw
    # merge algebra: the model's to_h minus the $ref and the slots
    # the document never wrote (present_slots).
    def siblings_of(node)
      present_slots(node).except("$ref")
    end

    # Folds the $ref target's non-object type terms into the node:
    # slots whose target is typed like ["object", "boolean"] render
    # the honest union (Klass | bool) instead of lying with the class
    # alone, which would under-accept the boolean/null instances the
    # schema allows. A pure-object target contributes nothing.
    def with_ref_types(node, target)
      extra = Array(target["type"]) - [TYPE_OBJECT]
      return node if extra.empty?

      merged = present_slots(node).merge("type" => Array(node.type) | extra)
      Schematrix::Meta::Schema.from_h(merged)
    end

    # Merges a raw $ref target with the referencing node's own
    # siblings (locals win) and loads the result back into the
    # model for the rest of the visit.
    def inline_model(target, node)
      Schematrix::Meta::Schema.from_h(target.merge(siblings_of(node)))
    end

    # Raw-node form of the map rule (see Schema#map_shaped?), applied
    # to $ref targets before they compile: the type stays within
    # {object, null} and includes object, there are no own properties,
    # no composition keyword could conjure properties back (those
    # targets keep the ref path and their class), and the catch-all is
    # not closed. Absent additionalProperties is the spec's untyped
    # catch-all unless closed_shapes was requested.
    def map_target?(target)
      types = Set.new(Array(target["type"]))
      own_properties = target["properties"]
      catch_all = target["additionalProperties"]
      return false unless types.include?(TYPE_OBJECT)
      return false unless (types - [TYPE_OBJECT, TYPE_NULL]).empty?
      return false unless own_properties.nil? || own_properties.empty?
      return false if composes?(target)
      return false if catch_all.is_a?(FalseClass)
      return false if catch_all.nil? && @closed_shapes

      true
    end

    # Whether the node carries any composition keyword that merges
    # other schemas into itself (allOf branches, union keywords,
    # single-branch conditionals, dependent schemas).
    def composes?(target)
      %w[allOf anyOf oneOf then else dependentSchemas].any? do |keyword|
        !target[keyword].nil?
      end
    end

    # The document a locator belongs to, as a root locator.
    def document_base(locator)
      base = locator.dup
      base.fragment = "/"
      base
    end

    # Whether two locators belong to the same document: their keys
    # match once the fragments are stripped.
    def same_document?(one, other)
      @store.document_key(one) == @store.document_key(other)
    end

    # The URI relative references resolve against: the document of
    # the nearest dereferenced inline target, else this visitor's
    # document.
    def ref_base
      @ref_base || @locator
    end

    # Compiles a block against the given document as the reference
    # base; nil compiles against the current base. Nesting is safe:
    # the previous base is always restored.
    def with_ref_base(base)
      return yield if base.nil?

      previous = @ref_base
      @ref_base = base
      begin
        yield
      ensure
        @ref_base = previous
      end
    end

    # Static approximation for $dynamicRef: assume the dynamic
    # scope equals the ref base document (the document of the nearest
    # dereferenced inline target, else this visitor's document). Walk
    # up the containment chain from the ref site to the root and take
    # the nearest $dynamicAnchor with the referenced name; fall back
    # to the last matching anchor in document order; then
    # unresolvable (untyped + debug log). The name may be empty ("#"
    # in the metaschemas). Chain links that do not exist in the
    # current document are skipped: inside merged cross-document
    # branches the chain mixes segments from both documents and can
    # point at nodes that do not exist here.
    def dynamic_anchor_locator(site, reference)
      name = reference.delete_prefix("#")
      chain = site[0...-1] # the ref site itself is not its own ancestor
      until chain.empty?
        locator = locator_for(chain)
        node = safe_node_at(locator)
        if node.is_a?(Hash) && node["$dynamicAnchor"] == name
          return locator.to_s
        end

        chain = chain[0...-1]
      end

      pointer = @store.last_dynamic_anchor_locator(ref_base, name)
      pointer&.to_s
    end

    # node_at that tolerates locators pointing outside this
    # document's shape: a missing link contributes nothing to the
    # anchor walk instead of failing the whole resolution.
    def safe_node_at(locator)
      @store.node_at(locator)
    rescue UnresolvableLocatorError
      nil
    end

    # Follows chains of pure references to the final node, guarding
    # against cycles. Returns the node and its locator. A landed node
    # whose $ref sits beside shape-applying keywords ends the chain:
    # 2020-12 applies both, so that node is the reference's target and
    # its own $ref applies when the node compiles (see
    # resolve_reference); following it would resolve past the target.
    def final_target(base, reference, seen = Set.new)
      locator = URI.join(base, reference)
      locator.fragment = "/" if locator.fragment.nil?
      locator = @store.canonicalize(locator)

      return nil, nil unless seen.add?(locator.to_s)

      node = @store.node_at(locator)
      reference = node.is_a?(Hash) ? node["$ref"] : nil
      return node, locator if reference.nil?
      if SHAPE_SIBLINGS.any? { |keyword| node.key?(keyword) }
        return node, locator
      end

      target, target_locator = final_target(locator, reference, seen)
      target ? [target, target_locator] : [node, locator]
    end

    # The locator URI for a path of containment segments, leading
    # empty segment included ([""] names the document root itself).
    def locator_for(path)
      fragment = path.join("/")
      locator = @locator.dup
      locator.fragment = fragment.empty? ? "/" : fragment
      locator
    end

    # The string form of a path's locator: the object registry key.
    def current_locator(path)
      locator_for(path).to_s
    end

    # Visit subtrees (other than properties), like items or
    # additionalProperties, that contain nested schema definition. The
    # branch comes from a model slot: a model instance or a boolean
    # schema.
    def visit_subtree(path, branch_name, branch)
      return nil if branch.nil?

      visit_schema(path, branch_name, branch)
    end

    # Visits prefixItems entries as value schemas. All entries
    # share the "prefixItems" path segment: inline object entries
    # register no class (their numeric position is not a valid class
    # name; they fall back to untyped in the element union), while $ref
    # entries keep their target's class through the recorded edge.
    def visit_prefix_items(path, node)
      node.prefix_items&.map do |item|
        visit_schema(path, "prefixItems", item, register_object: false)
      end || []
    end

    # maps a const value to its JSON Schema type when the mapping
    # is clean; nil means no inference (arrays, objects as const
    # values fall back to untyped).
    def const_type(value)
      case value
      when String
        TYPE_STRING
      when Integer
        TYPE_INTEGER
      when Float
        TYPE_NUMBER
      when TrueClass, FalseClass
        TYPE_BOOLEAN
      when NilClass
        TYPE_NULL
      end
    end

    # additionalProperties normalization: the spec default is
    # permissive, so absence behaves like true (untyped catch-all)
    # and only an explicit false closes the shape. nil (meaning
    # "no catch-all" to the templates) survives only for false, or
    # for absence when closed_shapes was requested.
    def visit_additional_properties(path, node)
      branch = node.additional_properties
      return nil if branch.is_a?(FalseClass)
      return nil if branch.nil? && @closed_shapes
      return Schema::Empty if branch.nil?

      # required: false: the catch-all schema is not a constructor
      # argument, so its type renders as an optional union (and gets
      # parenthesized in method-type positions)
      visit_schema(path, "additionalProperties", branch, required: false)
    end

    # Visits anyOf/oneOf branches in value context, one Schema per
    # branch, in the matching variant list. Branch locators use
    # anyOf_0 / oneOf_0 path segments. Object branches inside
    # oneOf register positional classes (OneOf0); anyOf branches do not
    # register (they merge). $ref branches keep working through
    # resolve_reference, recording their edge. A false branch accepts
    # nothing and contributes no variant.
    def visit_variant_list(path, keyword, branches)
      branches.each_with_index.filter_map do |branch, index|
        next if branch.is_a?(FalseClass)

        register_object = keyword == "oneOf"
        visit_schema(path, "#{keyword}_#{index}", branch, register_object:)
      end
    end

    # Splits a value-context node's composition branches. Inline
    # object branches inside anyOf are mergeable into the node's own
    # class; everything else stays a variant, including $ref
    # branches to objects (their target keeps its own class via the
    # recorded edge).
    def split_value_branches(node)
      any_branches = Array(node.any_of)
      mergeable, any_variants =
        any_branches.partition do |branch|
          branch.is_a?(Schematrix::Meta::Schema) && branch.ref.nil? &&
            Array(branch.type).include?(TYPE_OBJECT)
        end
      { mergeable:, any_of: any_variants, one_of: Array(node.one_of) }
    end

    # Object-context composition: merge the branch
    # properties of every composition keyword into one property set,
    # parent first, then branches in document order. allOf conjoins
    # (required unions, conflicting types intersect); the union
    # keywords merge optional branches with the untyped-contribution
    # rule inside anyOf/oneOf lists; then/else/dependentSchemas
    # are single branches and merge their own properties only; `if` is
    # a condition and is ignored.
    def compile_object(path, node)
      body = node_body(path, node)
      Array(node.all_of).each { |raw| body = conjoin_body(path, body, raw) }
      body = union_list_body(path, body, node.any_of)
      body = union_list_body(path, body, node.one_of)
      body = union_body(path, body, node.then_)
      body = union_body(path, body, node.else_)
      node.dependent_schemas.to_a.each do |_key, raw|
        body = union_body(path, body, raw)
      end
      body
    end

    # Merges inline object branches of a value-level anyOf into the
    # node's own class: union semantics with the
    # untyped-contribution rule, every property optional.
    def merge_value_branches(path, node, branches)
      union_list_body(path, node_body(path, node), branches)
    end

    # Value-context allOf fold: the branches conjoin into the slot's
    # record. A branch declaring an inline object shape absorbs into
    # the slot's own class, its properties merging under this site
    # (the object-context rule); everything else visits as a value
    # and conjoins: scalar branches intersect their type terms, and a
    # $ref branch keeps its target class through the recorded edge.
    # A true branch is the identity and a false branch is skipped
    # (over-accepting, like every other skipped false).
    def fold_value_allof(path, schema, raws)
      Array(raws).each_with_index do |raw, index|
        next unless raw.is_a?(Schematrix::Meta::Schema)

        if raw.ref.nil? && Array(raw.type).include?(TYPE_OBJECT)
          body =
            conjoin_body(
              path,
              Body.new(
                properties: schema.properties,
                additional_properties: schema.additional_properties,
              ),
              raw,
            )
          schema =
            schema.with(
              type: schema.type | Set[TYPE_OBJECT],
              properties: body.properties,
              additional_properties: body.additional_properties,
            )
          next
        end

        branch =
          visit_schema(
            path,
            "allOf_#{index}",
            raw,
            required: false,
            register_object: false,
          )
        next if branch.type == Set[TYPE_BOTTOM]

        schema = conjoin_schemas(schema, branch)
      end
      schema
    end

    # The mergeable parts of a raw node: its own properties and its
    # normalized additionalProperties.
    def node_body(path, node)
      Body.new(
        properties: compile_properties(path, node),
        additional_properties: visit_additional_properties(path, node),
      )
    end

    # Follows a $ref branch to its final target for merging (a flat
    # merge, no inheritance). The branch itself records no edge and
    # registers no class (merging produces no dead code); value
    # references nested inside its properties still record their
    # edges, because those classes are referenced from the merged
    # result. The branch's content compiles against the target's
    # document, so nested relative refs resolve where they were
    # written. Boolean targets contribute an open body (true) or
    # nothing at all (false, uninhabitable, over-accepting like every
    # skipped false branch).
    def branch_body(path, raw)
      unless raw.is_a?(Schematrix::Meta::Schema) && !raw.ref.nil?
        return node_body(path, raw)
      end

      target, locator = final_target(ref_base, raw.ref)
      return node_body(path, raw) if target.nil?

      if target == true
        Body.new(properties: {}, additional_properties: Schema::Empty)
      elsif target == false
        nil
      else
        with_ref_base(document_base(locator)) do
          node_body(path, Schematrix::Meta::Schema.from_h(target))
        end
      end
    end

    # Visits a node's own properties at the given path. Shared by
    # the node itself and by merged branches, so nested classes of a
    # merged branch land under the merging node's locator.
    def compile_properties(path, node)
      required_props = Set.new(node.required)
      properties_path = path + ["properties"]
      pairs =
        node.properties.filter_map do |prop_name, body|
          schema =
            visit_schema(
              properties_path,
              prop_name,
              body,
              required: required_props.include?(prop_name),
            )
          [prop_name, schema]
        end
      pairs.to_h
    end

    # allOf fold (conjunction): properties conjoin, required unions,
    # additionalProperties intersects. A `true` branch is the identity;
    # a `false` branch would make the schema uninhabitable and is
    # skipped (approximation: over-accepting, never under-accepting).
    def conjoin_body(path, acc, raw)
      return acc unless raw.is_a?(Schematrix::Meta::Schema)

      branch = branch_body(path, raw)
      return acc if branch.nil?

      properties =
        acc
          .properties
          .merge(branch.properties) do |_name, own, other|
            conjoin_schemas(own, other)
          end
      Body.new(
        properties:,
        additional_properties:
          conjoin_additional(
            acc.additional_properties,
            branch.additional_properties,
          ),
      )
    end

    # anyOf/oneOf fold: union semantics. Branches that
    # do not constrain a property contribute untyped to its union,
    # so properties mentioned by only some branches are not
    # over-constrained; branch-introduced properties are optional,
    # the parent's own required-ness survives.
    def union_list_body(path, acc, list)
      compiled =
        Array(list).filter_map do |raw|
          # a true branch owns no properties and a fully open shape;
          # pooling it gives every property an untyped contribution
          if raw == true
            next Body.new(properties: {}, additional_properties: Schema::Empty)
          end
          next nil if raw == false || !raw.is_a?(Schematrix::Meta::Schema)

          branch_body(path, raw)
        end
      return acc if compiled.empty?

      pool = acc.properties.dup
      names = compiled.flat_map { |body| body.properties.keys }.uniq
      names.each do |name|
        own = acc.properties[name]
        contribs = compiled.map { |body| body.properties[name] || :untyped }
        contribs.unshift(own) if own
        pool[name] = union_schemas(contribs, parent: own)
      end
      additional =
        compiled.reduce(acc.additional_properties) do |own, body|
          union_additional(own, body.additional_properties)
        end
      Body.new(properties: pool, additional_properties: additional)
    end

    # Single union branch (then/else/dependentSchemas entry): merges
    # its own properties as optional, no phantom untyped from
    # siblings (each keyword entry is one schema, not a list of
    # alternatives).
    def union_body(path, acc, raw)
      return acc unless raw.is_a?(Schematrix::Meta::Schema)

      branch = branch_body(path, raw)
      return acc if branch.nil?

      properties =
        acc
          .properties
          .merge(branch.properties) do |_name, own, other|
            union_schemas([own, other], parent: own)
          end
      Body.new(
        properties:,
        additional_properties:
          union_additional(
            acc.additional_properties,
            branch.additional_properties,
          ),
      )
    end

    # Conflict rule: distinct declarations of the same property
    # conjoin syntactically (String & Integer / T.all), even if
    # uninhabited; that is the schema author's problem. Facets beyond
    # type/ref/variants keep the parent's declaration.
    def conjoin_schemas(own, other)
      return own if own == other

      own.with(
        type: own.type | other.type,
        items: conjoin_items(own, other),
        ref: own.ref || other.ref,
        any_of: own.any_of + other.any_of,
        one_of: own.one_of + other.one_of,
        required: own.required || other.required,
        intersection: true,
      )
    end

    # allOf element intersection: array declarations conjoin their
    # items (an open tail is the identity, since it accepts any
    # element); declarations that are not arrays say nothing about
    # the element and leave it alone.
    def conjoin_items(own, other)
      unless own.type.include?(TYPE_ARRAY) && other.type.include?(TYPE_ARRAY)
        return own.items
      end
      return other.items if own.items.nil?
      return own.items if other.items.nil?

      conjoin_schemas(own.items, other.items)
    end

    # Union of property contributions. :untyped marks a branch that
    # does not constrain the property; it swallows the whole
    # union, because any value is then acceptable for some branch.
    # A bottom (false) contribution accepts nothing, so it
    # contributes nothing; every-bottom is bottom.
    def union_schemas(contribs, parent: nil)
      required = parent&.required || false
      has_untyped = contribs.include?(:untyped)
      has_untyped ||= contribs.any? { |c| c.is_a?(Schema) && c.untyped? }
      return Schema::Empty.with(required:) if has_untyped

      schemas = contribs.reject { |schema| schema.type == Set[TYPE_BOTTOM] }
      return contribs.first if schemas.empty?
      return schemas.first if schemas.size == 1

      schemas.first.with(
        type: schemas.reduce(Set.new) { |set, schema| set | schema.type },
        items: union_items(schemas),
        prefix_items: union_prefix_items(schemas),
        ref: schemas.filter_map(&:ref).first,
        any_of: schemas.flat_map(&:any_of),
        one_of: schemas.flat_map(&:one_of),
        required:,
      )
    end

    # Element terms of the union: array-typed contributions merge
    # their items instead of letting the first one win silently (an
    # instance from a later branch would then miss its declared
    # type); an open tail (items nil) accepts any element and widens
    # the element union to untyped.
    def union_items(schemas)
      arrays = schemas.select { |schema| schema.type.include?(TYPE_ARRAY) }
      return arrays.first&.items if arrays.size <= 1
      return nil if arrays.any? { |schema| schema.items.nil? }

      # Element schemas are never absent (only the catch-all schema
      # visits with required: false), so the merged element keeps the
      # required-ness every contribution was visited with instead of
      # the pool default, which would nilable-wrap the element.
      union_schemas(arrays.filter_map(&:items)).with(required: true)
    end

    # Tuple terms of the union: prefix items of distinct array
    # contributions have no positional merge, so differing tuples
    # widen to no tuple constraint and the items union alone speaks
    # for the element.
    def union_prefix_items(schemas)
      arrays = schemas.select { |schema| schema.type.include?(TYPE_ARRAY) }
      return arrays.first&.prefix_items if arrays.size <= 1
      return [] if arrays.map(&:prefix_items).uniq.size > 1

      arrays.first.prefix_items
    end

    # allOf intersects additionalProperties: any false closes
    # the result; untyped (absent) is the identity; declared schemas
    # conjoin.
    def conjoin_additional(own, other)
      return nil if own.nil? || other.nil?

      decls = [own, other].reject(&:untyped?)
      return Schema::Empty if decls.empty?
      return decls.first if decls.size == 1

      conjoin_schemas(decls.first, decls.last)
    end

    # Union branches open the shape: untyped wins, a closed
    # (false) branch contributes nothing because an instance from
    # another branch may still carry extra keys, and declared schemas
    # union their types. A $ref surviving on one side names the
    # catch-all of both; distinct refs have no single class to name,
    # so both drop and the type set alone speaks. A nil side loses to
    # a declared schema (the closed branch's instances simply carry
    # no extras); nil on both sides stays closed.
    def union_additional(own, other)
      return other if own.nil?
      return own if other.nil?

      return Schema::Empty if own.untyped? || other.untyped?

      refs = [own.ref, other.ref].compact.uniq
      own.with(
        type: own.type | other.type,
        ref: refs.size == 1 ? refs.first : nil,
        any_of: own.any_of + other.any_of,
        one_of: own.one_of + other.one_of,
      )
    end
  end
end
