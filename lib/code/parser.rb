class Code
  class Parser
    attr_reader :current

    def initialize(input, current: 0)
      @input = input
      @start = current
      @current = current
      @output = []
      @at_end = false
    end

    def self.parse(input)
      new(input).parse
    end

    def parse
      until at_end?
        @start = current
        c = advance

        if c == "'"
          single_quoted_string
        elsif c == '"'
          double_quoted_string
        elsif c == "}"
          @at_end = true
        else
          identifier
        end
      end

      output
    end

    private

    attr_reader :input, :start, :buffer, :output

    def peek
      input[current]
    end

    def at_end?
      current >= input.size || @at_end
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

    def identifier
      advance while peek != "}" && !at_end?

      value = input[start...current]

      if value == "nothing" || value == "null" || value == "nil"
        @output << { nothing: { value: value } }
      elsif value == "true" || value == "false"
        @output << { boolean: { value: value } }
      else
        @output << { variable: { value: value } }
      end
    end

    def single_quoted_string
      while peek != "'" && !at_end?
        if peek == "\\"
          advance
        end

        advance
      end

      if at_end?
        syntax_error(:unterminated_single_quoted_string)
      end

      advance

      @output << { string: { value: escape_string(input[(start + 1)...(current - 1)]) } }
    end

    def double_quoted_string
      while peek != '"' && !at_end?
        if peek == "\\"
          advance
        end

        advance
      end

      if at_end?
        syntax_error(:unterminated_single_quoted_string)
      end

      advance

      @output << { string: { value: escape_string(input[(start + 1)...(current - 1)]) } }
    end

    def escape_string(string)
      string
        .gsub("\\n", "\n")
        .gsub("\\t", "\t")
        .gsub("\\a", "\a")
        .gsub("\\r", "\r")
        .gsub("\\s", "\s")
        .gsub("\\a", "\a")
        .gsub(/\\(.)/, '\1')
    end
  end
end
