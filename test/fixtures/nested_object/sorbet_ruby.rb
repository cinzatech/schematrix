# typed: strict

module M
  class Schema
    sig { params(child: T.nilable(Schema::Child)).void }
    def initialize(child: nil)
      @child = child
    end

    sig { returns(T.nilable(Schema::Child)) }
    attr_accessor :child
  end
end
