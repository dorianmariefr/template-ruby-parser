class Code
  class Parser
    attr_reader :current, :start, :end_of_input

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

    SPECIAL = [
      SINGLE_QUOTE, DOUBLE_QUOTE, OPENING_CURLY_BRACKET, CLOSING_CURLY_BRACKET,
      OPENING_SQUARE_BRACKET, CLOSING_SQUARE_BRACKET, BACKSLASH, DOT, COMMA,
      SPACE, SLASH, ASTERISK, NEWLINE, HASH, COLON, EQUAL, GREATER, LESSER,
      OPENING_PARENTHESIS, CLOSING_PARENTHESIS, AMPERSAND, PIPE
    ]

    def initialize(input, current: 0, start: 0, expect_end_of_input: true)
      @input = input
      @start = start
      @current = current
      @output = []
      @end_of_input = false
      @has_space = true
      @expect_end_of_input = expect_end_of_input
    end

    def self.parse(input)
      new(input).parse
    end

    def parse
      until end_of_input?
        add(parse_subclass(::Code::Parser::Dictionnary))
      end

      if expect_end_of_input? && current < input.size
        syntax_error("Unexpected end of input")
      end

      output
    end

    private

    attr_reader :input, :buffer, :output

    def next?(expected)
      if expected.is_a?(Array)
        expected.any? { |e| next?(e) }
      else
        input[current, expected.size] == expected
      end
    end

    def next_next?(expected)
      if expected.is_a?(Array)
        expected.any? { |e| next_next?(e) }
      else
        input[current + 1, expected.size] == expected
      end
    end

    def has_space?
      !!@has_space
    end

    def expect_end_of_input?
      !!@expect_end_of_input
    end

    def end_of_input?
      current >= input.size || @end_of_input
    end

    def advance
      @current += 1
      input[current - 1]
    end

    def match(expected)
      if expected.is_a?(Array)
        expected.any? { |e| match(e) }
      elsif end_of_input? || input[current, expected.size] != expected
        false
      else
        @current += expected.size
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
      current - start + 1
    end

    def parse_code
      parse_subclass(::Code::Parser)
    end

    def add(output)
      @output << output if output
      output
    end

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
      @end_of_input = code_parser.end_of_input
      @start = code_parser.start
      output
    end
  end
end
