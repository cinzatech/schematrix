# typed: strict

module M
  class Schema
    sig { params(entries: T.nilable(T::Array[Schema::Entries::Items])).void }
    def initialize(entries: nil)
      @entries = entries
    end

    sig { returns(T.nilable(T::Array[Schema::Entries::Items])) }
    attr_accessor :entries
  end
end
