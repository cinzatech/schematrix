module M
  class FormatAnnotation
    def initialize(email: nil)
      @email = email
    end

    attr_accessor :email
  end
end
