class Code
  class Parser
    class Call < ::Code::Parser
      def parse
        return if end_of_input?
        return if next?(SPECIAL)

        consume while !next?(SPECIAL) && !end_of_input?

        identifier = buffer!

        if match(OPENING_PARENTHESIS)
          arguments = []

          code = parse_code
          arguments << code if code

          while match(COMMA) && !end_of_input?
            code = parse_code
            arguments << code if code
          end

          match(CLOSING_PARENTHESIS)
        else
          arguments = nil
        end

        if arguments
          { call: { name: identifier, arguments: arguments } }
        else
          { call: identifier }
        end
      end
    end
  end
end
