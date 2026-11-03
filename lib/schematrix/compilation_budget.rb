module Schematrix
  class CompilationLimitError < StandardError
  end

  # Cumulative work allowance shared by every visitor in one compiler.
  class CompilationBudget
    DEFAULT_LIMIT = 100_000

    attr_reader :remaining

    def initialize(limit = DEFAULT_LIMIT)
      unless limit.is_a?(Integer) && limit.positive?
        raise ArgumentError, "max_compilation_work must be a positive integer"
      end

      @limit = limit
      @remaining = limit
    end

    def consume!(amount = 1)
      if amount > @remaining
        raise CompilationLimitError,
              "Compilation work limit exceeded (#{@limit})"
      end

      @remaining -= amount
    end
  end
end
