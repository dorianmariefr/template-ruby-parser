class Code
  class Parser
    class Comment < ::Code::Parser
      def parse
        if match(HASH) || match(SLASH + SLASH)
          advance while !next?(NEWLINE) && !end_of_input?

          match(NEWLINE)

          { comment: input[start...current] }
        else
          parse_subclass(::Code::Parser::MultiLineComment)
        end
      end
    end
  end
end
