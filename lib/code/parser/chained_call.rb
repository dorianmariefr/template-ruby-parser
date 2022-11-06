class Code
  class Parser
    class ChainedCall < ::Code::Parser
      def parse
        previous_cursor = cursor
        left = parse_dictionnary
        consume while next?(WHITESPACE)

        if left && match(DOT) && (right = parse_dictionnary)
          consume while next?(WHITESPACE)
          chained_call = [{ left: left, right: right }]
          while match(DOT) && other_right = parse_dictionnary
            chained_call << { right: other_right }
          end
          chained_call
        else
          buffer!
          @cursor = previous_cursor
          parse_dictionnary
        end
      end

      def parse_dictionnary
        parse_subclass(::Code::Parser::Dictionnary)
      end
    end
  end
end
