class Code
  class Parser
    class Negation < ::Code::Parser
      def parse
        if match(EXCLAMATION_POINT)
          { negation: parse_subclass(::Code::Parser::Negation) }
        else
          parse_subclass(::Code::Parser::Function)
        end
      end
    end
  end
end
