# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "note" => :note, "id" => :id }.freeze, T::Hash[String, Symbol])

    sig { params(id: Integer, note: T.nilable(String)).void }
    def initialize(id:, note: nil)
      @note = note
      @id = id

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :note

    sig { returns(Integer) }
    attr_accessor :id

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(note: hash["note"], id: hash["id"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["note"] = @note unless @note.nil?
      result["id"] = @id unless @id.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
