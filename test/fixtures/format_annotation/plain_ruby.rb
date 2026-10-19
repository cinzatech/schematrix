module M
  class Schema
    ORIGINAL_KEYS = { "email" => :email }.freeze

    def initialize(email: nil)
      @email = email

      @_extra = {}
    end

    attr_accessor :email

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(email: hash["email"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["email"] = @email unless @email.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
