class Code
  class Parser
    class Nothing < ::Code::Parser
      def parse
        match(NOTHING_KEYWORDS) ? { nothing: buffer } : nil
      end
    end
  end
end
