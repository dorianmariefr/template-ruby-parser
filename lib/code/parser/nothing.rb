class Code
  class Parser
    class Nothing < ::Code::Parser
      def parse
        if match(NOTHING_KEYWORDS)
          { nothing: buffer }
        else
          consume(1)
          nil
        end
      end
    end
  end
end
