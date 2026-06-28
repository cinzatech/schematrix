module M
  class PatternProps
    def initialize(config: nil)
      @config = config
    end

    attr_accessor :config
  end
end
