class Code
  class Parser
    class Identifier < ::Code::Parser
      def initialize(input, simple: false, **kargs)
        super(input, **kargs)
        @simple = simple
      end

      def parse
        return if end_of_input?

        if !simple? && match(AMPERSAND)
          { block: parse_subclass(::Code::Parser::Statement) }
        elsif !simple && match(ASTERISK + ASTERISK)
          { keyword_splat: parse_subclass(::Code::Parser::Statement) }
        elsif !simple? && match(ASTERISK)
          { regular_splat: parse_subclass(::Code::Parser::Statement) }
        elsif !next?(SPECIAL) && !next?(KEYWORDS)
          consume while !next?(SPECIAL) && !end_of_input?

          match(QUESTION_MARK) || match(EXCLAMATION_POINT) if !simple?

          name = buffer!

          { name: name }
        else
          return
        end
      end

      private

      attr_reader :simple

      def simple?
        !!simple
      end
    end
  end
end
