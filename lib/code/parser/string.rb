class Code
  class Parser
    class String < ::Code::Parser
      def parse
        if match(DOUBLE_QUOTE)
          parse_string(DOUBLE_QUOTE)
        elsif match(SINGLE_QUOTE)
          parse_string(SINGLE_QUOTE)
        elsif match(COLON)
          advance while !next?(SPECIAL) && !end_of_input?

          { string: input[(start + 1)...current] }
        else
          parse_subclass(::Code::Parser::Comment)
        end
      end

      private

      def parse_string(quote)
        buffer = EMPTY_STRING
        output = []

        while !next?(quote) && !end_of_input?
          c = advance

          if c == BACKSLASH
            if match(quote)
              buffer += quote
            elsif match(OPENING_CURLY_BRACKET)
              buffer += OPENING_CURLY_BRACKET
            else
              buffer += c
            end
          elsif c == OPENING_CURLY_BRACKET
            if buffer != EMPTY_STRING
              output << { text: escape_string(buffer) }
              buffer = EMPTY_STRING
            end

            output << { code: parse_code }
          else
            buffer += c
          end
        end

        advance if !end_of_input?

        output << { text: escape_string(buffer) } if buffer != EMPTY_STRING

        { string: output }
      end

      def escape_string(string)
        string
          .gsub(SPECIAL_BELL, SPECIAL_BELL_ESCAPED)
          .gsub(SPECIAL_BACKSPACE, SPECIAL_BACKSPACE_ESCAPED)
          .gsub(SPECIAL_CARRIAGE_RETURN, SPECIAL_CARRIAGE_RETURN_ESCAPED)
          .gsub(SPECIAL_NEWLINE, SPECIAL_NEWLINE_ESCAPED)
          .gsub(SPECIAL_SPACE, SPECIAL_SPACE_ESCAPED)
          .gsub(SPECIAL_TAB, SPECIAL_TAB_ESCAPED)
          .gsub(/\\(.)/, '\1')
      end
    end
  end
end
