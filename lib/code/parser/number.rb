class Code
  class Parser
    class Number < ::Code::Parser
      def parse
        if match(DIGITS)
          if match(X)
            parse_base(16)
          elsif match(O)
            parse_base(8)
          elsif match(B)
            parse_base(2)
          else
            consume while (next?(DIGITS) || next?(UNDERSCORE)) && !end_of_input?

            if next?(DOT) && next_next?(DIGITS)
              consume
              consume while (next?(DIGITS) || next?(UNDERSCORE)) && !end_of_input?

              { decimal: buffer.gsub(UNDERSCORE, EMPTY_STRING) }
            else
              { integer: buffer.gsub(UNDERSCORE, EMPTY_STRING).to_i }
            end
          end
        else
          parse_subclass(::Code::Parser::Boolean)
        end
      end

      def parse_base(base)
        buffer!
        consume while (next?(DIGITS) || next?(UNDERSCORE)) && !end_of_input?

        { integer: buffer.gsub(UNDERSCORE, EMPTY_STRING).to_i(base) }
      end
    end
  end
end
