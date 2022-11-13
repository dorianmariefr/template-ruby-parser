class Code
  class Parser
    class Equal < ::Code::Parser
      def parse
        left = parse_subclass(::Code::Parser::Rescue)

        previous_cursor = cursor

        comments_before = parse_comments

        if operator = match(EQUALS)
          comments_after = parse_comments

          right = parse_subclass(::Code::Parser::Equal)

          if right
            {
              equal: {
                left: left,
                right: right,
                comments_before: comments_before,
                comments_after: comments_after
              }.compact
            }
          else
            @cursor = previous_cursor
            buffer!
            left
          end
        else
          @cursor = previous_cursor
          buffer!
          left
        end
      end
    end
  end
end
