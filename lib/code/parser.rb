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
      SPACE, SLASH, ASTERISK, NEWLINE, HASH, COLON, EQUAL, GREATER, LESSER,
      OPENING_PARENTHESIS, CLOSING_PARENTHESIS, AMPERSAND
    ]

    def initialize(input, current: 0)
      @input = input
      @start = current
      @current = current
      @output = []
      @end_of_input = false
      @has_space = true
    end

    def self.parse(input)
      new(input).parse
    end

    def parse
      until end_of_input?
        @start = current
        c = advance

        if c == SPACE
          @has_space = true
        elsif c == NEWLINE
          @has_space = true
          @output << { newline: c }
        elsif c == CLOSING_CURLY_BRACKET
          @end_of_input = true
        elsif has_space?
          @has_space = false

          if DIGITS.include?(c)
            parse_number
          elsif c == OPENING_SQUARE_BRACKET
            parse_list
          elsif c == OPENING_CURLY_BRACKET
            parse_dictionnary
          elsif c == SINGLE_QUOTE
            parse_string(SINGLE_QUOTE)
          elsif c == DOUBLE_QUOTE
            parse_string(DOUBLE_QUOTE)
          elsif c == HASH
            parse_comment
          elsif c == COLON && !next?(SPECIAL)
            parse_symbol
          elsif c == OPENING_PARENTHESIS
            parse_group
          elsif c == AMPERSAND
            parse_variable(offset: 1, block: true)
          elsif c == ASTERISK
            if match(ASTERISK)
              parse_variable(offset: 2, splat: :keyword)
            else
              parse_variable(offset: 1, splat: :regular)
            end
          elsif c == SLASH
            if match(ASTERISK)
              parse_multi_line_comment
            elsif match(SLASH)
              parse_comment
            else
              raise NotImplementedError
            end
          elsif !SPECIAL.include?(c)
            parse_identifier
          else
            @current -= 1
            @end_of_input = true
          end
        else
          @current -= 1
          @end_of_input = true
        end
      end

      output
    end

    private

    attr_reader :input, :start, :buffer, :output

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

    def end_of_input?
      current >= input.size || @end_of_input
    end

    def advance
      @current += 1
      input[current - 1]
    end

    def match(expected)
      if end_of_input? || input[current, expected.size] != expected
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
      advance while !next?(SPECIAL) && !end_of_input?

      identifier = input[start...current]

      if identifier == NOTHING_KEYWORD || identifier == NULL_KEYWORD ||
           identifier == NIL_KEYWORD
        @output << { nothing: identifier }
      elsif identifier == TRUE_KEYWORD || identifier == FALSE_KEYWORD
        @output << { boolean: identifier }
      else
        return if parse_call({ name: identifier })
        @output << { variable: identifier }
      end
    end

    def parse_variable(offset:, **args)
      advance while !next?(SPECIAL) && !end_of_input?

      variable = { name: input[(start + offset)...current], **args }

      return if parse_call(variable)

      @output << { variable: variable }
    end

    def parse_string(quote)
      buffer = EMPTY_STRING
      output = []

      while !next?(quote) && !end_of_input?
        c = advance

        if c == BACKSLASH
          if match(quote)
            buffer += quote
          elsif match(OPENING_CURLY_BRACKET)
            buffer += OPENING_CURLY_BRACKET
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

      advance if !end_of_input?

      output << { text: escape_string(buffer) } if buffer != EMPTY_STRING

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
      advance while next?(DIGITS)

      if next?(DOT) && next_next?(DIGITS)
        advance

        advance while next?(DIGITS)

        @output << { decimal: input[start...current] }
      else
        @output << { integer: input[start...current] }
      end
    end

    def parse_list
      list = []

      code = parse_code

      list << code if code.any?

      while next?(COMMA) && !end_of_input?
        advance

        code = parse_code

        list << code if code.any?
      end

      advance if !end_of_input?

      @output << { list: list }
    end

    def parse_multi_line_comment
      advance while !next?(ASTERISK) && !next_next?(SLASH) && !end_of_input?

      if !end_of_input?
        advance
        advance
      end

      @output << { comment: input[start...current] }
    end

    def parse_comment
      advance while !next?(NEWLINE) && !end_of_input?

      advance if !end_of_input?

      @output << { comment: input[start...current] }
    end

    def parse_dictionnary_key_value
      key = parse_code

      return if key.empty?

      if next?(COLON) || next?(EQUAL + GREATER)
        if next?(COLON)
          advance
        else
          advance
          advance
        end

        value = parse_code

        { key: key, value: value }
      else
        { key: key }
      end
    end

    def parse_dictionnary
      dictionnary = []

      dictionnary << parse_dictionnary_key_value

      while next?(COMMA) && !end_of_input?
        advance

        dictionnary << parse_dictionnary_key_value
      end

      match(CLOSING_CURLY_BRACKET)

      @output << { dictionnary: dictionnary.compact }
    end

    def parse_group
      @output << { group: parse_code }

      match(CLOSING_PARENTHESIS)
    end

    def parse_call(variable)
      if match(OPENING_PARENTHESIS)
        arguments = []
        code = parse_code

        arguments << code if code.any?

        while next?(COMMA) && !end_of_input?
          advance

          code = parse_code
          arguments << code if code.any?
        end

        arguments = nil if arguments.empty?

        match(CLOSING_PARENTHESIS)

        @output << { call: { **variable.merge(arguments: arguments).compact } }

        true
      else
        false
      end
    end

    def parse_symbol
      advance while !next?(SPECIAL) && !end_of_input?

      @output << { string: input[(start + 1)...current] }
    end
  end
end
