class Code
  class Parser
    class MultiLineComment < ::Code::Parser
      def parse
        if match(SLASH + ASTERISK)
          advance while !next?(ASTERISK) && !next_next?(SLASH) && !end_of_input?

          match(SLASH)
          match(ASTERISK)

          { comment: input[start...current] }
        else
          parse_subclass(::Code::Parser::Call)
        end
      end
    end
  end
end
