class Code
  class Parser
    class UnaryMinus < ::Code::Parser
      def parse
        if (operator = match(MINUS)) || (operator = match(PLUS))
          comments = parse_comments
          right = parse_subclass(::Code::Parser::UnaryMinus)

          {
            unary_minus: {
              right: right,
              comments: comments,
              operator: operator
            }.compact
          }
        else
          parse_subclass(::Code::Parser::Power)
        end
      end
    end
  end
end
