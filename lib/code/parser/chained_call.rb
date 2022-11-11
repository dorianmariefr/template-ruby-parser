class Code
  class Parser
    class ChainedCall < ::Code::Parser
      def parse
        previous_cursor = cursor
        left = parse_dictionnary
        before_comments = parse_comments

        if left && match(DOT)
          after_comments = parse_comments
          right = parse_dictionnary
          if right
            chained_call = [{ left: left, right: right }]
            while match(DOT) && other_right = parse_dictionnary
              chained_call << { right: other_right }
            end
            {
              chained_call: {
                calls: chained_call,
                before_comments: before_comments,
                after_comments: after_comments
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
