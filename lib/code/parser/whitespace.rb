class Code
  class Parser
    class Whitespace < ::Code::Parser
      def parse
        if match(SPACE)
          @has_space = true
          nil
        elsif match(NEWLINE)
          @has_space = true
          { newline: NEWLINE }
        elsif match(CLOSING_CURLY_BRACKET)
          nil
        else
          advance
          nil
        end
      end
    end
  end
end
