# typed: strict

module M
  class MultiRef
    sig { params(home: T.anything, work: T.anything).void }
    def initialize(home: nil, work: nil)
      @home = home
      @work = work
    end

    sig { returns(T.anything) }
    attr_accessor :home

    sig { returns(T.anything) }
    attr_accessor :work
  end
end
