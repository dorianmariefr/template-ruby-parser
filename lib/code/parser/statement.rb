class Code
  class Parser
    class Statement < ::Code::Parser
      def parse
        parse_subclass(::Code::Parser::GreaterThan)
      end
    end
  end
end
