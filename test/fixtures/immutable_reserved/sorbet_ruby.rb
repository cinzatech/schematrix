# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "with" => :with_, "_extra" => :_extra_, "count" => :count }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        with_: String,
        _extra_: T.nilable(Integer),
        count: T.nilable(Integer)
      ).void
    end
    def initialize(with_:, _extra_: nil, count: nil)
      @with_ = with_
      @_extra_ = _extra_
      @count = count
      freeze
    end

    sig { returns(String) }
    attr_reader :with_

    sig { returns(T.nilable(Integer)) }
    attr_reader :_extra_

    sig { returns(T.nilable(Integer)) }
    attr_reader :count

    sig do
      params(
        with_: String,
        _extra_: T.nilable(Integer),
        count: T.nilable(Integer)
      ).returns(T.self_type)
    end
    def with(with_: @with_, _extra_: @_extra_, count: @count)
      self.class.new(with_: with_, _extra_: _extra_, count: count)
    end

    sig { params(other: T.untyped).returns(T::Boolean) }
    def ==(other)
      other.is_a?(self.class) && other.with_ == @with_ &&
        other._extra_ == @_extra_ && other.count == @count
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
      [self.class, @with_, @_extra_, @count].hash
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      kwargs = {}
      kwargs[:with_] = hash["with"]
      kwargs[:_extra_] = hash["_extra"]
      kwargs[:count] = hash["count"]
      new(**kwargs)
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["with"] = @with_ unless @with_.nil?
      result["_extra"] = @_extra_ unless @_extra_.nil?
      result["count"] = @count unless @count.nil?
      result
    end
  end
end
