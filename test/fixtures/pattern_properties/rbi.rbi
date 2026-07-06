# typed: strict

module M
  class Schema
    sig { params(config: T.nilable(Schema::Config)).void }
    def initialize(config: nil)
    end

    sig { returns(T.nilable(Schema::Config)) }
    def config
    end

    sig { params(config: T.nilable(Schema::Config)).void }
    def config=(config)
    end
  end
end
