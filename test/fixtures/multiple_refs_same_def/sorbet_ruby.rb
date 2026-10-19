# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "home" => :home, "work" => :work }.freeze

    sig do
      params(
        home: T.nilable(Schema::Defs::Address),
        work: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, work: nil)
      @home = home
      @work = work

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :home

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :work

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_home(value)
      if value.is_a?(M::Schema::Defs::Address)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Address.from_h(value)
      else
        value
      end
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_work(value)
      if value.is_a?(M::Schema::Defs::Address)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Address.from_h(value)
      else
        value
      end
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(home: coerce_home(hash["home"]), work: coerce_work(hash["work"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["home"] = self.class.coerce_home(@home) unless @home.nil?
      result["work"] = self.class.coerce_work(@work) unless @work.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
