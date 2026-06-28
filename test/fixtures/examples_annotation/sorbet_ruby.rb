# typed: strict

module M
  class ExamplesAnnotation
    sig { params(name: T.nilable(String)).void }
    def initialize(name: nil)
      @name = name
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name
  end
end
