class Code
  class Parser
    class Identifier < ::Code::Parser
      def initialize(input, simple: false, **kargs)
        super(input, **kargs)
        @simple = simple
      end

      def parse
        return if end_of_input?

        previous_cursor = cursor

        if !simple? && match(AMPERSAND) && !next?(SPECIAL)
          kind = :block
        elsif !simple && match(ASTERISK + ASTERISK) && !next?(SPECIAL)
          kind = :keyword
        elsif !simple? && match(ASTERISK) && !next?(SPECIAL)
          kind = :regular
        elsif !next?(SPECIAL)
          kind = nil
        else
          @cursor = previous_cursor
          buffer!
          return
        end

        buffer!

        consume while !next?(SPECIAL) && !end_of_input?

        match(QUESTION_MARK) || match(EXCLAMATION_POINT) if !simple?

        name = buffer!

        if KEYWORDS.include?(name)
          @cursor = previous_cursor
          buffer!
          return
        else
          { name: name, kind: kind }.compact
        end
      end

      private

      attr_reader :simple

      def simple?
        !!simple
      end
    end
  end
end
