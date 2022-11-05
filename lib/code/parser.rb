class Code
  class Parser
    attr_accessor :input, :cursor, :buffer

    EMPTY_STRING = ""

    DIGITS = %w[0 1 2 3 4 5 6 7 8 9]
    NON_ZERO_DIGITS = %w[1 2 3 4 5 6 7 8 9]

    SINGLE_QUOTE = "'"
    DOUBLE_QUOTE = '"'
    OPENING_CURLY_BRACKET = "{"
    CLOSING_CURLY_BRACKET = "}"
    OPENING_SQUARE_BRACKET = "["
    CLOSING_SQUARE_BRACKET = "]"
    OPENING_PARENTHESIS = "("
    CLOSING_PARENTHESIS = ")"
    DOT = "."
    BACKSLASH = "\\"
    COMMA = ","
    SPACE = " "
    SLASH = "/"
    ASTERISK = "*"
    NEWLINE = "\n"
    HASH = "#"
    COLON = ":"
    EQUAL = "="
    GREATER = ">"
    LESSER = "<"
    AMPERSAND = "&"
    PIPE = "|"

    WHITESPACE = [SPACE, NEWLINE]

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
    DO_KEYWORD = "do"
    END_KEYWORD = "end"

    NOTHING_KEYWORDS = [NOTHING_KEYWORD, NULL_KEYWORD, NIL_KEYWORD]
    BOOLEAN_KEYWORDS = [TRUE_KEYWORD, FALSE_KEYWORD]
    KEYWORDS = NOTHING_KEYWORDS + BOOLEAN_KEYWORDS + [DO_KEYWORD, END_KEYWORD]

    SPECIAL = [
      SINGLE_QUOTE, DOUBLE_QUOTE, OPENING_CURLY_BRACKET, CLOSING_CURLY_BRACKET,
      OPENING_SQUARE_BRACKET, CLOSING_SQUARE_BRACKET, BACKSLASH, DOT, COMMA,
      SPACE, SLASH, ASTERISK, NEWLINE, HASH, COLON, EQUAL, GREATER, LESSER,
      OPENING_PARENTHESIS, CLOSING_PARENTHESIS, AMPERSAND, PIPE
    ]

    def initialize(
      input,
      cursor: 0,
      buffer: EMPTY_STRING,
      check_end_of_input: true
    )
      @input = input
      @cursor = cursor
      @buffer = buffer
      @check_end_of_input = check_end_of_input
    end

    def self.parse(input)
      new(input).parse
    end

    def parse
      output = parse_subclass(::Code::Parser::Code)

      if check_end_of_input && cursor != input.size
        syntax_error("Unexpected end of input")
      end

      output
    end

    private

    attr_reader :check_end_of_input

    def syntax_error(message)
      raise(
        ::Code::Parser::Error::SyntaxError.new(
          message,
          input: input,
          line: line,
          column: column,
          offset_lines: offset_lines,
          offset_columns: offset_columns
        )
      )
    end

    def line
      input[0...cursor].count("\n")
    end

    def column
      cursor - input.lines[0...line].map(&:size).sum
    end

    def offset_lines
      buffer.count("\n")
    end

    def offset_columns
      buffer.size + 1
    end

    def consume(n = 1)
      if cursor + n <= input.size
        @buffer += input[cursor, n]
        @cursor += n
      else
        syntax_error("Unexpected end of input")
      end
    end

    def add(output)
      @output << output if output
      output
    end

    def next?(expected)
      if expected.is_a?(Array)
        expected.any? { |e| next?(e) }
      else
        input[cursor, expected.size] == expected
      end
    end

    def match(expected)
      if expected.is_a?(Array)
        expected.any? { |e| match(e) }
      else
        if input[cursor, expected.size] == expected
          @buffer += expected
          @cursor += expected.size
          true
        else
          false
        end
      end
    end

    def parse_subclass(subclass)
      parser = subclass.new(input, cursor: cursor, check_end_of_input: false)
      output = parser.parse
      @cursor = parser.cursor
      output
    end

    def parse_code
      parse_subclass(::Code::Parser::Code)
    end

    def end_of_input?
      cursor >= input.size
    end

    def buffer?
      buffer != EMPTY_STRING
    end

    def buffer!
      buffer.tap { @buffer = EMPTY_STRING }
    end
  end
end
