class Code
  class Parser
    class Dictionnary < ::Code::Parser
      def parse
        if match(OPENING_CURLY_BRACKET)
          dictionnary = []

          dictionnary << parse_key_value

          dictionnary << parse_key_value while match(COMMA) && !end_of_input?

          match(CLOSING_CURLY_BRACKET)

          { dictionnary: dictionnary.compact }
        else
          parse_subclass(::Code::Parser::List)
        end
      end

      def parse_key_value
        consume while next?(WHITESPACE)

        key = parse_subclass(::Code::Parser::Statement)

        consume while next?(WHITESPACE)

        return unless key

        if match(COLON) || match(EQUAL + GREATER)
          { key: key, value: parse_code }
        else
          { key: key }
        end
      end
    end
  end
end
