# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "with" => :with_,
          "_extra" => :_extra_,
          "count" => :count,
          "hash" => :hash_
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        with_: String,
        _extra_: T.nilable(Integer),
        count: T.nilable(Integer),
        hash_: T.nilable(String)
      ).void
    end
    def initialize(with_:, _extra_: nil, count: nil, hash_: nil)
      @with_ = with_
      @_extra_ = _extra_
      @count = count
      @hash_ = hash_
      freeze
    end

    sig { returns(String) }
    attr_reader :with_

    sig { returns(T.nilable(Integer)) }
    attr_reader :_extra_

    sig { returns(T.nilable(Integer)) }
    attr_reader :count

    sig { returns(T.nilable(String)) }
    attr_reader :hash_

    sig do
      params(
        with_: String,
        _extra_: T.nilable(Integer),
        count: T.nilable(Integer),
        hash_: T.nilable(String)
      ).returns(T.self_type)
    end
    def with(with_: @with_, _extra_: @_extra_, count: @count, hash_: @hash_)
      self.class.new(with_: with_, _extra_: _extra_, count: count, hash_: hash_)
    end

    sig { params(other: T.untyped).returns(T::Boolean) }
    def ==(other)
      other.is_a?(self.class) && other.with_ == @with_ &&
        other._extra_ == @_extra_ && other.count == @count &&
        other.hash_ == @hash_
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
      [self.class, @with_, @_extra_, @count, @hash_].hash
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      kwargs = {}
      kwargs[:with_] = hash["with"]
      kwargs[:_extra_] = hash["_extra"]
      kwargs[:count] = hash["count"]
      kwargs[:hash_] = hash["hash"]
      new(**kwargs)
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["with"] = @with_ unless @with_.nil?
      result["_extra"] = @_extra_ unless @_extra_.nil?
      result["count"] = @count unless @count.nil?
      result["hash"] = @hash_ unless @hash_.nil?
      result
    end
  end
end
