class Code
  class Parser
    attr_reader :current

    EMPTY_STRING = ""
    SINGLE_QUOTE = "'"
    DOUBLE_QUOTE = '"'
    CLOSING_CURLY_BRACKET = "}"
    OPENING_CURLY_BRACKET = "{"
    DIGITS = %w[0 1 2 3 4 5 6 7 8 9]
    NON_ZERO_DIGITS = %w[1 2 3 4 5 6 7 8 9]
    BACKSLASH = "\\"
    SPECIAL_BELL = "\\a"
    SPECIAL_BELL_ESCAPED = "\a"
    SPECIAL_BACKSPACE = "\\b"
    SPECIAL_BACKSPACE_ESCAPED = "\b"
    SPECIAL_CARRIAGE_RETURN = "\\r"
    SPECIAL_CARRIAGE_RETURN_ESCAPED = "\r"
    SPECIAL_NEWLINE = "\\n"
    SPECIAL_NEWLINE_ESCAPED = "\n"
    SPECIAL_SPACE = "\\s"
    SPECIAL_SPACE_ESCAPED = "\s"
    SPECIAL_TAB = "\\t"
    SPECIAL_TAB_ESCAPED = "\t"
    NOTHING_KEYWORD = "nothing"
    NULL_KEYWORD = "null"
    NIL_KEYWORD = "nil"
    TRUE_KEYWORD = "true"
    FALSE_KEYWORD = "false"
    DOT = "."

    def initialize(input, current: 0)
      @input = input
      @start = current
      @current = current
      @output = []
      @end_of_input = false
    end

    def self.parse(input)
      new(input).parse
    end

    def parse
      until end_of_input?
        @start = current
        c = advance

        if DIGITS.include?(c)
          number
        elsif c == SINGLE_QUOTE
          string(SINGLE_QUOTE)
        elsif c == DOUBLE_QUOTE
          string(DOUBLE_QUOTE)
        elsif c == CLOSING_CURLY_BRACKET
          @end_of_input = true
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

    def end_of_input?
      current >= input.size || @end_of_input
    end

    def advance
      @current += 1
      input[current - 1]
    end

    def match(expected)
      if end_of_input? || input[current] != expected
        false
      else
        @current += 1
        true
      end
    end

    def syntax_error(reason)
      raise(
        ::Code::Parser::Error::SyntaxError.new(
          reason,
          input: input,
          line: line,
          column: column,
          offset_lines: offset_lines,
          offset_columns: offset_columns
        )
      )
    end

    def line
      input[0...start].count("\n")
    end

    def column
      start - input.lines[0...line].map(&:size).sum
    end

    def offset_lines
      input[0...current].count("\n") - line
    end

    def offset_columns
      current - start
    end

    def identifier
      advance while peek != CLOSING_CURLY_BRACKET && !end_of_input?

      value = input[start...current]

      if value == NOTHING_KEYWORD || value == NULL_KEYWORD ||
           value == NIL_KEYWORD
        @output << { nothing: value }
      elsif value == TRUE_KEYWORD || value == FALSE_KEYWORD
        @output << { boolean: value }
      else
        @output << { variable: value }
      end
    end

    def string(quote)
      buffer = EMPTY_STRING
      output = []

      while peek != quote && !end_of_input?
        c = advance

        if c == BACKSLASH
          if peek == quote
            advance
            buffer += quote
          elsif peek == OPENING_CURLY_BRACKET
            buffer += advance
          else
            buffer += c
          end
        elsif c == CLOSING_CURLY_BRACKET
          if buffer != EMPTY_STRING
            output << { text: escape_string(buffer) }
            buffer = EMPTY_STRING
          end

          code_parser = ::Code::Parser.new(input, current: current)
          output << { code: code_parser.parse }
          @current = code_parser.current
        else
          buffer += c
        end
      end

      syntax_error("Unterminated string, missing #{quote}") if end_of_input?

      output << { text: escape_string(buffer) } if buffer != EMPTY_STRING

      advance

      @output << { string: output }
    end

    def escape_string(string)
      string
        .gsub(SPECIAL_BELL, SPECIAL_BELL_ESCAPED)
        .gsub(SPECIAL_BACKSPACE, SPECIAL_BACKSPACE_ESCAPED)
        .gsub(SPECIAL_CARRIAGE_RETURN, SPECIAL_CARRIAGE_RETURN_ESCAPED)
        .gsub(SPECIAL_NEWLINE, SPECIAL_NEWLINE_ESCAPED)
        .gsub(SPECIAL_SPACE, SPECIAL_SPACE_ESCAPED)
        .gsub(SPECIAL_TAB, SPECIAL_TAB_ESCAPED)
        .gsub(/\\(.)/, '\1')
    end

    def number
      advance while DIGITS.include?(peek)

      if peek == DOT && DIGITS.include?(peek_next)
        advance

        advance while DIGITS.include?(peek)

        @output << { decimal: input[start...current] }
      else
        @output << { integer: input[start...current] }
      end
    end
  end
end
