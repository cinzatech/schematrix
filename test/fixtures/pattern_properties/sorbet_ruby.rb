# typed: strict

module M
  class Schema
    sig { params(config: T.nilable(Schema::Config)).void }
    def initialize(config: nil)
      @config = config
    end

    sig { returns(T.nilable(Schema::Config)) }
    attr_accessor :config
  end
end
