class Code
  class Parser
    class Power < ::Code::Parser
      def parse
        previous_cursor = cursor
        left = parse_subclass(::Code::Parser::Negation)
        parse_comments
        if match(ASTERISK + ASTERISK)
          parse_comments
          right = parse_subclass(::Code::Parser::Power)
          if right
            { power: { left: left, right: right } }
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