class Code
  class Parser
    class Dictionnary < ::Code::Parser
      def parse
        if match(OPENING_CURLY_BRACKET)
          dictionnary = []

          dictionnary << parse_dictionnary_key_value

          while next?(COMMA) && !end_of_input?
            advance

            dictionnary << parse_dictionnary_key_value
          end

          match(CLOSING_CURLY_BRACKET)

          { dictionnary: dictionnary.compact }
        else
          parse_subclass(::Code::Parser::List)
        end
      end

      private

      def parse_dictionnary_key_value
        key = parse_code

        return if key.empty?

        if next?(COLON) || next?(EQUAL + GREATER)
          if next?(COLON)
            advance
          else
            advance
            advance
          end

          value = parse_code

          { key: key, value: value }
        else
          { key: key }
        end
      end
    end
  end
end
