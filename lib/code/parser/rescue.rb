class Code
  class Parser
    class Rescue < ::Code::Parser
      def parse
        parse_subclass(::Code::Parser::Ternary)
      end
    end
  end
end
