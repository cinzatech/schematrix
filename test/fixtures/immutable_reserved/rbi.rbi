# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "with" => :with_,
      "_extra" => :_extra_,
      "count" => :count
    }.freeze

    sig do
      params(
        with_: String,
        _extra_: T.nilable(Integer),
        count: T.nilable(Integer)
      ).void
    end
    def initialize(with_:, _extra_: nil, count: nil)
    end

    sig { returns(String) }
    def with_
    end

    sig { returns(T.nilable(Integer)) }
    def _extra_
    end

    sig { returns(T.nilable(Integer)) }
    def count
    end

    sig do
      params(
        with_: String,
        _extra_: T.nilable(Integer),
        count: T.nilable(Integer)
      ).returns(T.self_type)
    end
    def with(with_: T.untyped, _extra_: T.untyped, count: T.untyped)
    end

    sig { params(other: T.anything).returns(T::Boolean) }
    def ==(other)
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
