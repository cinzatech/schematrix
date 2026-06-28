# typed: strict

module M
  # A described object
  class Described
    sig { params(name: T.nilable(String)).void }
    def initialize(name: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end
  end
end
