module M
  class Schema
    ORIGINAL_KEYS = {
      "with" => :with_,
      "_extra" => :_extra_,
      "count" => :count,
      "hash" => :hash_
    }.freeze

    def initialize(with_:, _extra_: nil, count: nil, hash_: nil)
      @with_ = with_
      @_extra_ = _extra_
      @count = count
      @hash_ = hash_
      freeze
    end

    attr_reader :with_, :_extra_, :count, :hash_

    def with(with_: @with_, _extra_: @_extra_, count: @count, hash_: @hash_)
      self.class.new(with_: with_, _extra_: _extra_, count: count, hash_: hash_)
    end

    def ==(other)
      other.is_a?(self.class) && other.with_ == @with_ &&
        other._extra_ == @_extra_ && other.count == @count &&
        other.hash_ == @hash_
    end

    alias eql? ==

    def hash
      [self.class, @with_, @_extra_, @count, @hash_].hash
    end

    def self.from_h(hash)
      kwargs = {}
      kwargs[:with_] = hash["with"]
      kwargs[:_extra_] = hash["_extra"]
      kwargs[:count] = hash["count"]
      kwargs[:hash_] = hash["hash"]
      new(**kwargs)
    end

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
