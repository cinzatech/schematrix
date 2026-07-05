# typed: strict

module M
  class Schema
    sig { params(data: T.anything).void }
    def initialize(data: nil)
      @data = data
    end

    sig { returns(T.anything) }
    attr_accessor :data
  end
end
