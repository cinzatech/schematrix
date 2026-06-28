# typed: strict

module M
  class Defaults
    sig { params(color: T.nilable(String), count: T.nilable(Integer)).void }
    def initialize(color: "blue", count: 0)
      @color = color
      @count = count
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :color

    sig { returns(T.nilable(Integer)) }
    attr_accessor :count
  end
end
