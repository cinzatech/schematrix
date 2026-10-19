# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name }.freeze

    sig { params(name: T.nilable(String)).void }
    def initialize(name: nil)
      @name = name
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      new(name: hash["name"])
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result
    end
  end
end
