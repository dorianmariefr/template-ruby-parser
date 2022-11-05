class Code
  class Parser
    class List < ::Code::Parser
      def parse
        if match(OPENING_SQUARE_BRACKET)
          list = []

          code = parse_code

          list << code if code.any?

          while next?(COMMA) && !end_of_input?
            advance

            code = parse_code

            list << code if code.any?
          end

          match(CLOSING_SQUARE_BRACKET)

          { list: list }
        else
          parse_subclass(::Code::Parser::Number)
        end
      end
    end
  end
end
