class Code
  class Parser
    class ChainedCall < ::Code::Parser
      def parse
        previous_cursor = cursor
        left = parse_dictionnary
        comments_before = parse_comments

        if left && match(DOT)
          comments_after = parse_comments
          right = parse_dictionnary
          if right
            chained_call = [{ left: left, right: right }]
            while match(DOT) && other_right = parse_dictionnary
              chained_call << { right: other_right }
            end
            {
              chained_call: {
                calls: chained_call,
                comments_before: comments_before,
                comments_after: comments_after
              }.compact
            }
          else
            @cursor = previous_cursor
            buffer!
            parse_dictionnary
          end
        else
          @cursor = previous_cursor
          buffer!
          parse_dictionnary
        end
      end

      def parse_dictionnary
        parse_subclass(::Code::Parser::Dictionnary)
      end
    end
  end
end
