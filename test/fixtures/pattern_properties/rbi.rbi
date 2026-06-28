# typed: strict

module M
  class PatternProps
    sig { params(config: T.nilable(T::Hash[String, String])).void }
    def initialize(config: nil)
    end

    sig { returns(T.nilable(T::Hash[String, String])) }
    def config
    end

    sig { params(config: T.nilable(T::Hash[String, String])).void }
    def config=(config)
    end
  end
end
