require "prism"

require_relative "test_helper"

# The exported RBI declares the library API with the parameter lists of
# the loaded code. Tapioca merges the file into the gem's RBI and
# refuses it on a conflict, so each declared method must exist on the
# constant that declares it, with the same parameters.
class TestRbi < Minitest::Test
  RBI_PATH = File.expand_path("../rbi/schematrix.rbi", __dir__)

  Declaration = Data.define(:owner, :singleton, :name, :parameters, :line)

  def test_every_declared_constant_is_loaded
    declarations
      .map(&:owner)
      .uniq
      .each do |owner|
        assert Object.const_defined?(owner),
               "#{owner} is declared but not loaded"
      end
  end

  def test_every_declared_method_matches_the_loaded_parameters
    declarations.each do |declaration|
      actual = loaded_parameters(declaration)
      assert_equal(
        declaration.parameters,
        actual,
        "#{RBI_PATH}:#{declaration.line}: #{describe(declaration)} differs " \
          "from the loaded method",
      )
    end
  end

  private

  def declarations
    @declarations ||= collect(Prism.parse_file(RBI_PATH).value, [], [])
  end

  def collect(node, scope, found)
    case node
    when Prism::ModuleNode, Prism::ClassNode
      inner = scope + [node.constant_path.full_name]
      node.body&.child_nodes&.each { |child| collect(child, inner, found) }
    when Prism::SingletonClassNode
      node.body&.child_nodes&.each do |child|
        collect(child, scope + [:singleton], found)
      end
    when Prism::DefNode
      found << declaration(node, scope)
    when Prism::Node
      node.child_nodes.compact.each { |child| collect(child, scope, found) }
    end
    found
  end

  def declaration(node, scope)
    singleton = scope.last == :singleton || !node.receiver.nil?
    Declaration.new(
      owner: scope.grep(String).join("::"),
      singleton:,
      name: node.name,
      parameters: parameters(node.parameters),
      line: node.location.start_line,
    )
  end

  def parameters(node)
    return [] if node.nil?

    node.requireds.map { |p| [:req, p.name] } +
      node.optionals.map { |p| [:opt, p.name] } +
      (node.rest ? [[:rest, node.rest.name]] : []) +
      node.keywords.map do |p|
        [p.is_a?(Prism::RequiredKeywordParameterNode) ? :keyreq : :key, p.name]
      end + (node.keyword_rest ? [[:keyrest, node.keyword_rest.name]] : []) +
      (node.block ? [[:block, node.block.name]] : [])
  end

  def loaded_parameters(declaration)
    owner = Object.const_get(declaration.owner)
    method =
      if declaration.singleton
        owner.method(declaration.name)
      else
        owner.instance_method(declaration.name)
      end
    # A writer made by attr_accessor reports its parameter without a
    # name; the declaration names it.
    method.parameters.map do |kind, name|
      [kind, name || declaration.parameters.assoc(kind)&.last]
    end
  rescue NameError => e
    flunk "#{RBI_PATH}:#{declaration.line}: #{describe(declaration)}: " \
            "#{e.message}"
  end

  def describe(declaration)
    separator = declaration.singleton ? "." : "#"
    "#{declaration.owner}#{separator}#{declaration.name}"
  end
end
