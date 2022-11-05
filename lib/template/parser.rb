class Template
  class Parser < ::Code::Parser
    def parse
      buffer = EMPTY_STRING
      output = []

      until end_of_input?
        c = advance

        if c == OPENING_CURLY_BRACKET
          if buffer != EMPTY_STRING
            output << { text: buffer }
            buffer = EMPTY_STRING
          end

          @start = current
          output << { code: parse_code }
        elsif c == BACKSLASH && match(OPENING_CURLY_BRACKET)
          buffer += OPENING_CURLY_BRACKET
        else
          buffer += c
        end
      end

      if buffer != EMPTY_STRING
        output << { text: buffer }
        buffer = EMPTY_STRING
      end

      output
    end

    private

    def parse_subclass(subclass, **args)
      code_parser =
        subclass.new(
          input,
          start: start,
          current: current,
          expect_end_of_input: false,
          **args
        )
      output = code_parser.parse
      @current = code_parser.current
      @start = code_parser.start
      output
    end
  end
end
