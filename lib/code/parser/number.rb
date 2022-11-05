class Code
  class Parser
    class Number < ::Code::Parser
      def parse
        if match(NON_ZERO_DIGITS)
          advance while next?(DIGITS)

          if next?(DOT) && next_next?(DIGITS)
            advance

            advance while next?(DIGITS)

            { decimal: input[start...current] }
          else
            { integer: input[start...current] }
          end
        else
          parse_subclass(::Code::Parser::String)
        end
      end
    end
  end
end
