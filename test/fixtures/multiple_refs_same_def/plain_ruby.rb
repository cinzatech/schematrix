require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "home" => :home, "work" => :work }.freeze

    def initialize(home: nil, work: nil)
      @home = home
      @work = work

      @_extra = {}
    end

    attr_accessor :home, :work

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_home(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Address])
    end

    def self.coerce_work(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Address])
    end

    def self.from_h(hash)
      instance =
        new(home: coerce_home(hash["home"]), work: coerce_work(hash["work"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["home"] = self.class.coerce_home(@home) unless @home.nil?
      result["work"] = self.class.coerce_work(@work) unless @work.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
