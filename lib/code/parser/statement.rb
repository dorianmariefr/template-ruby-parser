class Code
  class Parser
    class Statement < ::Code::Parser
      def parse
        parse_subclass(::Code::Parser::Negation)
      end
    end
  end
end
