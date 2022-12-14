class Code
  class Parser
    class AndOperator < ::Code::Parser
      def parse
        parse_subclass(
          ::Code::Parser::Operation,
          operators: [AMPERSAND + AMPERSAND],
          subclass: ::Code::Parser::Equality
        )
      end
    end
  end
end
