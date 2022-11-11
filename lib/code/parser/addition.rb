class Code
  class Parser
    class Addition < ::Code::Parser
      def parse
        left = parse_subclass(::Code::Parser::Multiplication)
        right = []
        previous_cursor = cursor
        comments = parse_comments

        while (operator = match(PLUS)) || (operator = match(MINUS))
          comments = parse_comments
          statement = parse_subclass(::Code::Parser::Multiplication)
          right << {
            comments: comments,
            statement: statement,
            operator: operator
          }.compact
        end

        if right.empty?
          @cursor = previous_cursor
          buffer!
          left
        else
          {
            addition: {
              left: left,
              comments: comments,
              right: right
            }.compact
          }
        end
      end
    end
  end
end
