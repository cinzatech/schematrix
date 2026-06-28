# typed: strict

module M
  class PatternProps
    sig { params(config: T.nilable(T::Hash[String, String])).void }
    def initialize(config: nil)
      @config = config
    end

    sig { returns(T.nilable(T::Hash[String, String])) }
    attr_accessor :config
  end
end
