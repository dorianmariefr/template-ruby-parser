class Code
  class Parser
    attr_reader :current

    EMPTY_STRING = ""

    DIGITS = %w[0 1 2 3 4 5 6 7 8 9]
    NON_ZERO_DIGITS = %w[1 2 3 4 5 6 7 8 9]

    SINGLE_QUOTE = "'"
    DOUBLE_QUOTE = '"'
    OPENING_CURLY_BRACKET = "{"
    CLOSING_CURLY_BRACKET = "}"
    OPENING_SQUARE_BRACKET = "["
    CLOSING_SQUARE_BRACKET = "]"
    DOT = "."
    BACKSLASH = "\\"
    COMMA = ","
    SPACE = " "
    SLASH = "/"
    ASTERISK = "*"
    NEWLINE = "\n"
    HASH = "#"

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

    SPECIAL = [
      SINGLE_QUOTE, DOUBLE_QUOTE, OPENING_CURLY_BRACKET, CLOSING_CURLY_BRACKET,
      OPENING_SQUARE_BRACKET, CLOSING_SQUARE_BRACKET, BACKSLASH, DOT, COMMA,
      SPACE, SLASH, ASTERISK, NEWLINE, HASH
    ]

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
          parse_number
        elsif c == OPENING_SQUARE_BRACKET
          parse_list
        elsif c == OPENING_CURLY_BRACKET
          parse_dicitionnary
        elsif c == SINGLE_QUOTE
          parse_string(SINGLE_QUOTE)
        elsif c == DOUBLE_QUOTE
          parse_string(DOUBLE_QUOTE)
        elsif c == CLOSING_CURLY_BRACKET
          @end_of_input = true
        elsif c == SPACE
        elsif c == NEWLINE
          @output << { newline: c }
        elsif c == HASH
          comment
        elsif c == SLASH
          if match(ASTERISK)
            multi_line_comment
          elsif match(SLASH)
            comment
          else
            raise NotImplementedError
          end
        elsif !SPECIAL.include?(c)
          parse_identifier
        else
          @current -= 1
          @end_of_input = true
        end
      end

      output
    end

    private

    attr_reader :input, :start, :buffer, :output

    def peek
      input[current]
    end

    def peek_next
      input[current + 1]
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

    def parse_code
      code_parser = ::Code::Parser.new(input, current: current)
      output = code_parser.parse
      @current = code_parser.current
      output
    end

    def parse_identifier
      advance while !SPECIAL.include?(peek) && !end_of_input?

      identifier = input[start...current]

      if identifier == NOTHING_KEYWORD || identifier == NULL_KEYWORD ||
           identifier == NIL_KEYWORD
        @output << { nothing: identifier }
      elsif identifier == TRUE_KEYWORD || identifier == FALSE_KEYWORD
        @output << { boolean: identifier }
      else
        @output << { variable: identifier }
      end
    end

    def parse_string(quote)
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
        elsif c == OPENING_CURLY_BRACKET
          if buffer != EMPTY_STRING
            output << { text: escape_string(buffer) }
            buffer = EMPTY_STRING
          end

          output << { code: parse_code }
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

    def parse_number
      advance while DIGITS.include?(peek)

      if peek == DOT && DIGITS.include?(peek_next)
        advance

        advance while DIGITS.include?(peek)

        @output << { decimal: input[start...current] }
      else
        @output << { integer: input[start...current] }
      end
    end

    def parse_list
      list = []

      code = parse_code

      list << code if code.any?

      while peek == COMMA && !end_of_input?
        advance

        list << parse_code
      end

      syntax_error("Unterminated list, missing ]") if end_of_input?

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

    def parse_number
      advance while DIGITS.include?(peek)

      if peek == DOT && DIGITS.include?(peek_next)
        advance

        advance while DIGITS.include?(peek)

        @output << { decimal: input[start...current] }
      else
        @output << { integer: input[start...current] }
      end
    end

    def parse_list
      list = []

      code = parse_code

      list << code if code.any?

      while peek == COMMA && !end_of_input?
        advance

        code = parse_code

        list << code if code.any?
      end

      advance

      @output << { list: list }
    end

    def multi_line_comment
      advance while peek != ASTERISK && peek_next != SLASH && !end_of_input?

      if !end_of_input?
        advance
        advance
      end

      @output << { comment: input[start...current] }
    end

    def comment
      advance while peek != NEWLINE && !end_of_input?

      advance if !end_of_input?

      @output << { comment: input[start...current] }
    end
  end
end
