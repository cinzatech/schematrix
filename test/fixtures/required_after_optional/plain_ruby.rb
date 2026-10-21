module M
  class Schema
    ORIGINAL_KEYS = { "note" => :note, "id" => :id }.freeze

    def initialize(id:, note: nil)
      @note = note
      @id = id

      @_extra = {}
    end

    attr_accessor :note, :id

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(note: hash["note"], id: hash["id"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["note"] = @note unless @note.nil?
      result["id"] = @id unless @id.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
