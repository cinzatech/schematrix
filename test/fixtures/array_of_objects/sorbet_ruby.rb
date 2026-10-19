# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "entries" => :entries }.freeze

    sig do
      params(entries: T.nilable(T::Array[Schema::Props::Entries::Items])).void
    end
    def initialize(entries: nil)
      @entries = entries

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[Schema::Props::Entries::Items])) }
    attr_accessor :entries

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_entries(value)
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(M::Schema::Props::Entries::Items)
          element.to_h
        elsif element.is_a?(Hash)
          M::Schema::Props::Entries::Items.from_h(element)
        else
          element
        end
      end
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(entries: coerce_entries(hash["entries"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["entries"] = self.class.coerce_entries(
        @entries
      ) unless @entries.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
