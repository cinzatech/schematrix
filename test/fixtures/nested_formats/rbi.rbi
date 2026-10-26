# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "log" => :log,
      "window" => :window,
      "rates" => :rates,
      "milestone" => :milestone,
      "amount" => :amount
    }.freeze

    sig do
      params(
        log: T.nilable(T::Array[Time]),
        window: T.nilable(T::Array[T.any(Date, Time)]),
        rates: T.nilable(T::Hash[String, Time]),
        milestone: T.nilable(T.any(Date, Integer)),
        amount: T.nilable(T.any(Time, Schema::Defs::Money))
      ).void
    end
    def initialize(
      log: nil,
      window: nil,
      rates: nil,
      milestone: nil,
      amount: nil
    )
    end

    sig { returns(T.nilable(T::Array[Time])) }
    def log
    end

    sig { params(log: T.nilable(T::Array[Time])).void }
    def log=(log)
    end

    sig { returns(T.nilable(T::Array[T.any(Date, Time)])) }
    def window
    end

    sig { params(window: T.nilable(T::Array[T.any(Date, Time)])).void }
    def window=(window)
    end

    sig { returns(T.nilable(T::Hash[String, Time])) }
    def rates
    end

    sig { params(rates: T.nilable(T::Hash[String, Time])).void }
    def rates=(rates)
    end

    sig { returns(T.nilable(T.any(Date, Integer))) }
    def milestone
    end

    sig { params(milestone: T.nilable(T.any(Date, Integer))).void }
    def milestone=(milestone)
    end

    sig { returns(T.nilable(T.any(Time, Schema::Defs::Money))) }
    def amount
    end

    sig { params(amount: T.nilable(T.any(Time, Schema::Defs::Money))).void }
    def amount=(amount)
    end

    sig { params(key: String).returns(T.nilable(Date)) }
    def [](key)
    end

    sig { params(key: String, value: T.nilable(Date)).returns(T.nilable(Date)) }
    def []=(key, value)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_class_slot(value, klass)
    end

    sig { params(value: T.anything, spec: T.anything).returns(T.anything) }
    def self.coerce_spec(value, spec)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_extra(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_log(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_window(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_rates(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_milestone(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_amount(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end

  module Schematrix
    module Coercers
      module DateTime
        sig { params(value: T.anything).returns(T.anything) }
        def self.coerce(value)
        end
      end

      module Date
        sig { params(value: T.anything).returns(T.anything) }
        def self.coerce(value)
        end
      end
    end
  end
end
