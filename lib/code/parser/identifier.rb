class Code
  class Parser
    class Identifier < ::Code::Parser
      def parse
        return if end_of_input?
        return if next?(SPECIAL) && !next?(AMPERSAND) && !next?(ASTERISK)
        return if next?(KEYWORDS)

        block = match(AMPERSAND) || nil

        if match(ASTERISK + ASTERISK)
          splat = :keyword
        elsif match(ASTERISK)
          splat = :regular
        else
          splat = nil
        end

        buffer!

        consume while !next?(SPECIAL) && !end_of_input?

        match(QUESTION_MARK) || match(EXCLAMATION_POINT)

        name = buffer!

        { name: name, block: block, splat: splat }.compact
      end
    end
  end
end
