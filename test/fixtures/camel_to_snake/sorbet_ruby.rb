# typed: strict

module M
  class CamelCase
    sig do
      params(first_name: T.nilable(String), last_name: T.nilable(String)).void
    end
    def initialize(first_name: nil, last_name: nil)
      @first_name = first_name
      @last_name = last_name
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :first_name

    sig { returns(T.nilable(String)) }
    attr_accessor :last_name
  end
end
