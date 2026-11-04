module Schematrix
  module Generators
    module Templates
      module DslParserRuntime
        BODY = <<~'RUBY'
          # Reports source coordinates with callback failures retained as causes.
          class ParseError < StandardError
            attr_reader :filename, :line, :column, :keyword, :reason

            def initialize(filename:, line:, column:, keyword:, reason:)
              @filename = filename
              @line = line
              @column = column
              @keyword = keyword
              @reason = reason
              super("#{filename}:#{line}:#{column}: #{keyword}: #{reason}")
            end
          end

          def self.parse(source, filename:, contract:)
            Walker.new(filename).parse(source, contract)
          end

          # Holds lexical namespaces and diagnostic state for one parse invocation.
          class Walker
            SIGNATURES = {
              scalar: [1..1, :forbidden],
              object: [0..0, :required],
              array_scalars: [0.., :forbidden],
              array_objects: [0..0, :required],
              mixed_array: [0.., :optional],
              mixed_value: [0..1, :optional],
              map_scalars: [2..2, :forbidden],
              map_objects: [1..1, :required],
              extra_scalars: [2..2, :forbidden],
              extra_objects: [1..1, :required],
            }.freeze

            def initialize(filename)
              @filename = filename
              @nesting = []
              @keyword = "source"
            end

            def parse(source, contract)
              result = Prism.parse(source, filepath: @filename)
              unless result.success?
                error = result.errors.first
                fail_at(error.location, error.message)
              end
              if result.data_loc
                fail_at(result.data_loc, "trailing data is not supported")
              end
              entry(statements(result.value.statements), contract)
            end

            private

            def fail_at(node, reason)
              location = node.respond_to?(:location) ? node.location : node
              error =
                ParseError.new(
                  filename: @filename,
                  line: location&.start_line || 1,
                  column: (location&.start_character_column || 0) + 1,
                  keyword: @keyword,
                  reason: reason,
                )
              raise error
            end

            def statements(node)
              return [] if node.nil?

              unless node.is_a?(Prism::StatementsNode)
                fail_at(node, "only plain statements are supported")
              end
              node.body
            end

            def entry(nodes, contract)
              unless nodes.length == 1
                fail_at(nodes[1] || nodes.first, "expected exactly one document")
              end
              node = nodes.first
              case node
              when Prism::ModuleNode, Prism::ClassNode
                declaration(node, contract)
              when Prism::CallNode
                valid = node.name == :build && !node.safe_navigation?
                valid &&= constant_path(node.receiver) == contract.fetch(:builder)
                valid &&= arguments(node).empty?
                fail_at(node, "expected the qualified builder.build entry") unless valid
                document(block_body(node.block, node), contract)
              else
                fail_at(node, "unsupported document entry")
              end
            end

            def declaration(node, contract)
              if node.is_a?(Prism::ClassNode) && node.superclass
                fail_at(node, "class superclasses are not supported")
              end
              path = constant_path(node.constant_path)
              fail_at(node, "invalid declaration name") unless path
              rooted = node.constant_path.location.slice.start_with?("::")
              full = rooted || @nesting.empty? ? path : "#{@nesting.first}::#{path}"
              @nesting.unshift(full)
              body = statements(node.body)
              first = body.first
              if first.is_a?(Prism::CallNode) && first.name == :extend
                valid = first.receiver.nil? && first.block.nil?
                valid &&= arguments(first).length == 1
                valid &&=
                  constant_path(arguments(first).first) == contract.fetch(:builder)
                fail_at(first, "expected extend with the qualified builder") unless valid
                document(body.drop(1), contract)
              else
                wrapper = first.is_a?(Prism::ModuleNode) || first.is_a?(Prism::ClassNode)
                unless body.length == 1 && wrapper
                  fail_at(first || node, "declaration body must start with extend")
                end
                entry(body, contract)
              end
            ensure
              @nesting.shift if full
            end

            def arguments(node)
              args = node.arguments&.arguments || []
              args.each do |arg|
                unsupported = arg.is_a?(Prism::SplatNode)
                unsupported ||= arg.is_a?(Prism::ForwardingArgumentsNode)
                unsupported ||=
                  arg.is_a?(Prism::KeywordHashNode) && !positional_hash?(arg)
                next unless unsupported

                fail_at(arg, "splats, forwarding and keyword arguments are not supported")
              end
              args
            end

            def positional_hash?(node)
              node.elements.all? do |element|
                element.is_a?(Prism::AssocNode) && element.key.is_a?(Prism::StringNode)
              end
            end

            def block_body(block, node)
              if block.nil?
                fail_at(node, "expected a block")
              end
              unless block.is_a?(Prism::BlockNode) && block.parameters.nil?
                fail_at(block, "expected a literal block without parameters")
              end
              statements(block.body)
            end

            def document(nodes, contract)
              output = {}
              nodes.each do |node|
                unless node.is_a?(Prism::CallNode) && node.receiver.nil?
                  fail_at(node, "expected a receiverless setter call")
                end
                @keyword = node.name.to_s
                setter = contract.fetch(:setters)[@keyword]
                fail_at(node, "unknown setter") unless setter
                apply(output, node, setter)
              end
              output
            end

            def apply(output, node, setter)
              args = arguments(node)
              kind = setter.fetch(:kind)
              count, block = SIGNATURES.fetch(kind)
              fail_at(node, "wrong argument count") unless count.cover?(args.length)
              if block == :forbidden && node.block
                fail_at(node.block, "block is not permitted")
              end
              body = block_body(node.block, node) if node.block || block == :required
              key = setter[:key]
              spec = setter[:value]
              case kind
              when :scalar
                output[key] = value(args.first, spec)
              when :object, :mixed_value
                if body
                  check_ignored_value(args.first, spec) unless args.empty?
                  child = document(body, setter.fetch(:child).call)
                  current = output[key]
                  output[key] = current.is_a?(Hash) ? current.merge(child) : child
                else
                  output[key] = (
                    if args.empty?
                      normalize(nil, spec, node)
                    else
                      value(args.first, spec)
                    end
                  )
                end
              when :array_scalars, :array_objects, :mixed_array
                target = container(output, key, Array, node)
                args.each { |arg| target << value(arg, array_item(spec, target.length)) }
                target << document(body, setter.fetch(:child).call) if body
              when :map_scalars, :map_objects, :extra_scalars, :extra_objects
                target =
                  (
                    if kind.to_s.start_with?("extra")
                      output
                    else
                      container(output, key, Hash, node)
                    end
                  )
                entry_key = value(args.first, nil)
                target[entry_key] = (
                  if body
                    document(body, setter.fetch(:child).call)
                  else
                    value(args.last, spec)
                  end
                )
              end
            end

            def container(output, key, klass, node)
              target = output[key] ||= klass.new
              fail_at(node, "existing value is not a #{klass}") unless target.is_a?(klass)
              target
            end

            def array_item(spec, index)
              return nil unless spec

              if spec.first == :union
                spec = branches(spec).find { |branch| branch.first == :array }
              end
              return nil unless spec && spec.first == :array

              index < spec[1].length ? spec[1][index] : spec[2]
            end

            def branches(spec)
              return [] unless spec
              if spec.first == :union
                return spec[1].flat_map { |branch| branches(branch) }
              end

              [spec]
            end

            def value(node, spec)
              case node
              when Prism::ArrayNode
                structural = branches(spec).find { |branch| branch.first == :array }
                result =
                  node.elements.each_with_index.map do |element, index|
                    if element.is_a?(Prism::SplatNode)
                      fail_at(element, "array splats are not supported")
                    end
                    value(element, array_item(structural, index))
                  end
                structural ? result : normalize(result, spec, node)
              when Prism::HashNode, Prism::KeywordHashNode
                structural = branches(spec).find { |branch| branch.first == :map }
                result =
                  node.elements.to_h do |element|
                    unless element.is_a?(Prism::AssocNode)
                      fail_at(element, "hash splats are not supported")
                    end
                    [value(element.key, nil), value(element.value, structural&.[](1))]
                  end
                structural ? result : normalize(result, spec, node)
              when Prism::StringNode
                normalize(node.unescaped, spec, node)
              when Prism::IntegerNode, Prism::FloatNode
                normalize(node.value, spec, node)
              when Prism::TrueNode
                normalize(true, spec, node)
              when Prism::FalseNode
                normalize(false, spec, node)
              when Prism::NilNode
                normalize(nil, spec, node)
              else
                expression(node, spec)
              end
            end

            def check_ignored_value(node, spec)
              @ignoring_value = true
              value(node, spec)
            ensure
              @ignoring_value = false
            end

            def normalize(literal, spec, node)
              return literal if @ignoring_value

              normalizers =
                branches(spec).filter_map { |branch| branch[2] if branch.first == :value }
              normalizers.each do |normalizer|
                converted = with_error(node) { normalizer.call(literal) }
                return converted unless converted.equal?(literal)
              end
              literal
            end

            def expression(node, spec)
              scalar_specs = branches(spec).select { |branch| branch.first == :value }
              path = constant_path(node)
              if path
                mapping =
                  scalar_specs.each_with_object({}) do |branch, all|
                    all.merge!(branch[3] || {})
                  end
                candidates = [path]
                unless node.location.slice.start_with?("::")
                  candidates.concat(@nesting.map { |namespace| "#{namespace}::#{path}" })
                end
                matches = candidates.uniq.select { |candidate| mapping.key?(candidate) }
                fail_at(node, "ambiguous enum constant") if matches.length > 1
                return with_error(node) { mapping.fetch(matches.first).call } if matches.length == 1
              end
              reader = scalar_specs.filter_map { |branch| branch[1] }.first
              return with_error(node) { reader.call(node) } if reader

              fail_at(node, "unsupported value expression")
            end

            def with_error(node)
              yield
            rescue StandardError => e
              fail_at(node, e.message)
            end

            def constant_path(node)
              case node
              when Prism::ConstantReadNode
                node.name.to_s
              when Prism::ConstantPathNode
                if node.parent.nil?
                  node.location.slice.delete_prefix("::")
                else
                  parent = constant_path(node.parent)
                  "#{parent}::#{node.name}" if parent
                end
              end
            end
          end
        RUBY
      end
    end
  end
end
