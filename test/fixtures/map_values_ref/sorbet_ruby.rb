# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "vars" => :vars }.freeze

    sig { params(vars: T.nilable(T::Hash[String, Schema::Defs::Value])).void }
    def initialize(vars: nil)
      @vars = vars

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, Schema::Defs::Value])) }
    attr_accessor :vars

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_vars(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(M::Schema::Defs::Value)
          entry.to_h
        elsif entry.is_a?(Hash)
          M::Schema::Defs::Value.from_h(entry)
        else
          entry
        end
      end
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(vars: coerce_vars(hash["vars"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["vars"] = self.class.coerce_vars(@vars) unless @vars.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
