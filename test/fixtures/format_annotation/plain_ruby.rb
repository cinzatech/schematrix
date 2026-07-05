module M
  class Schema
    def initialize(email: nil)
      @email = email
    end

    attr_accessor :email
  end
end
