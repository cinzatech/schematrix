# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "status" => :status }.freeze, T::Hash[String, Symbol])

    sig { params(status: T.nilable(Schema::Props::Status)).void }
    def initialize(status:)
      @status = status
    end

    sig { returns(T.nilable(Schema::Props::Status)) }
    attr_accessor :status

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_status(value)
      ::M::Schema::Props::Status.coerce(value)
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      new(status: coerce_status(hash["status"]))
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["status"] = self.class.coerce_status(@status) unless @status.nil?
      result
    end
  end
end
