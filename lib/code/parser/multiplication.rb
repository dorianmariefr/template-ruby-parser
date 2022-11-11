class Code
  class Parser
    class Multiplication < ::Code::Parser
      def parse
        previous_cursor = cursor
        left = parse_subclass(::Code::Parser::UnaryMinus)
        right = []
        comments = parse_comments

        while (operator = match(ASTERISK)) || (operator = match(SLASH))
          comments = parse_comments
          statement = parse_subclass(::Code::Parser::UnaryMinus)
          right << { comments: comments, statement: statement, operator: operator }.compact
        end

        if right.empty?
          @cursor = previous_cursor
          buffer!
          parse_subclass(::Code::Parser::UnaryMinus)
        else
          { multiplication: { left: left, comments: comments, right: right }.compact }
        end
      end
    end
  end
end
