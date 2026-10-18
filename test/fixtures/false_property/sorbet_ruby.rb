# typed: strict

module M
  class Schema
    sig { params(name: T.nilable(String), legacy: T.nilable(T.noreturn)).void }
    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(T.noreturn)) }
    attr_accessor :legacy
  end
end
