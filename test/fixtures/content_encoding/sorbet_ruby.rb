# typed: strict

module M
  class ContentEnc
    sig { params(data: T.nilable(String)).void }
    def initialize(data: nil)
      @data = data
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :data
  end
end
