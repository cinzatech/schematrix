module M
  class Schema
    ORIGINAL_KEYS = {
      "with" => :with_,
      "_extra" => :_extra_,
      "count" => :count
    }.freeze

    def initialize(with_:, _extra_: nil, count: nil)
      @with_ = with_
      @_extra_ = _extra_
      @count = count
      freeze
    end

    attr_reader :with_, :_extra_, :count

    def with(with_: @with_, _extra_: @_extra_, count: @count)
      self.class.new(with_: with_, _extra_: _extra_, count: count)
    end

    def ==(other)
      other.is_a?(self.class) && other.with_ == @with_ &&
        other._extra_ == @_extra_ && other.count == @count
    end

    alias eql? ==

    def hash
      [self.class, @with_, @_extra_, @count].hash
    end

    def self.from_h(hash)
      kwargs = {}
      kwargs[:with_] = hash["with"]
      kwargs[:_extra_] = hash["_extra"]
      kwargs[:count] = hash["count"]
      new(**kwargs)
    end

    def to_h
      result = {}
      result["with"] = @with_ unless @with_.nil?
      result["_extra"] = @_extra_ unless @_extra_.nil?
      result["count"] = @count unless @count.nil?
      result
    end
  end
end
