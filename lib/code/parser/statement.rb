class Code
  class Parser
    class Statement < ::Code::Parser
      def parse
        parse_subclass(::Code::Parser::While)
      end
    end
  end
end
