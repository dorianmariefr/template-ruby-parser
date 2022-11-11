class Code
  class Parser
    class Identifier < ::Code::Parser
      def parse
        return if end_of_input?

        previous_cursor = cursor

        if match(AMPERSAND) && !next?(SPECIAL)
          kind = :block
        elsif match(ASTERISK + ASTERISK) && !next?(SPECIAL)
          kind = :keyword
        elsif match(ASTERISK) && !next?(SPECIAL)
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

        match(QUESTION_MARK) || match(EXCLAMATION_POINT)

        name = buffer!

        { name: name, kind: kind }.compact
      end
    end
  end
end
