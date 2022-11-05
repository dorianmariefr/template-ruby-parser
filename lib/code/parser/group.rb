class Code
  class Parser
    class Group < ::Code::Parser
      def parse
        if match(OPENING_PARENTHESIS)
          code = parse_code

          match(CLOSING_PARENTHESIS)

          { group: code }
        else
          parse_subclass(::Code::Parser::Whitespace)
        end
      end
    end
  end
end
