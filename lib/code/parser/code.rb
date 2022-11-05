class Code
  class Parser
    class Code < ::Code::Parser
      def parse
        consume while next?(WHITESPACE)

        output = []

        while code = parse_subclass(::Code::Parser::Statement)
          output << code
          consume while next?(WHITESPACE)
        end

        output
      end
    end
  end
end
