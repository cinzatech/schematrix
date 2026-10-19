module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name
    }.freeze

    def initialize(first_name: nil, last_name: nil)
      @first_name = first_name
      @last_name = last_name

      @_extra = {}
    end

    attr_accessor :first_name, :last_name

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(first_name: hash["firstName"], last_name: hash["lastName"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["firstName"] = @first_name unless @first_name.nil?
      result["lastName"] = @last_name unless @last_name.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
