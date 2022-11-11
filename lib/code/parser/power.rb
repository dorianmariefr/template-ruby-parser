class Code
  class Parser
    class Power < ::Code::Parser
      def parse
        previous_cursor = cursor
        left = parse_subclass(::Code::Parser::Negation)
        comments_before = parse_comments
        if match(ASTERISK + ASTERISK)
          comments_after = parse_comments
          right = parse_subclass(::Code::Parser::Power)
          if right
            {
              power: {
                left: left,
                right: right,
                comments_before: comments_before,
                comments_after: comments_after
              }.compact
            }
          else
            @cursor = previous_cursor
            buffer!
            parse_subclass(::Code::Parser::Negation)
          end
        else
          @cursor = previous_cursor
          buffer!
          parse_subclass(::Code::Parser::Negation)
        end
      end
    end
  end
end
