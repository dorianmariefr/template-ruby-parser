class Template
  class Parser
    def initialize(input)
      @input = input
      @current = 0
      @output = []
      @buffer = ""
    end

    def self.parse(input)
      new(input).parse
    end

    def parse
      until at_end?
        c = advance

        if c == "\\"
          if match("{")
            @buffer += "{"
          else
            @buffer += c
          end
        elsif c == "{"
          if buffer != ""
            @output << { text: buffer }
            @buffer = ""
          end

          code_parser =
            ::Code::Parser.new(
              input,
              current: current,
              expect_end_of_input: false
            )
          @output << { code: code_parser.parse }
          @current = code_parser.current
        else
          @buffer += c
        end
      end

      if buffer != ""
        @output << { text: buffer }
        @buffer = ""
      end

      output
    end

    private

    attr_reader :input, :current, :buffer, :output

    def at_end?
      current >= input.size
    end

    def advance
      @current += 1
      input[current - 1]
    end

    def match(expected)
      if at_end? || input[current] != expected
        false
      else
        @current += 1
        true
      end
    end
  end
end
