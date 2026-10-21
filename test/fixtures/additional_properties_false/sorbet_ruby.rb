# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "name" => :name }.freeze, T::Hash[String, Symbol])

    sig { params(name: T.nilable(String)).void }
    def initialize(name: nil)
      @name = name
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      new(name: hash["name"])
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result
    end
  end
end
