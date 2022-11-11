class Code
  class Parser
    class Identifier < ::Code::Parser
      def parse
        return if end_of_input?
        return if next?(SPECIAL) && !next?(AMPERSAND) && !next?(ASTERISK)
        return if next?(KEYWORDS)

        if match(AMPERSAND)
          kind = :block
        elsif match(ASTERISK + ASTERISK)
          kind = :keyword
        elsif match(ASTERISK)
          kind = :regular
        else
          kind = nil
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
