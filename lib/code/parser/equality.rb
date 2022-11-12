class Code
  class Parser
    class Equality < ::Code::Parser
      def parse
        parse_subclass(
          ::Code::Parser::Operation,
          operators: [EQUAL + EQUAL, EXCLAMATION_POINT + EQUAL],
          subclass: ::Code::Parser::While
        )
      end
    end
  end
end
