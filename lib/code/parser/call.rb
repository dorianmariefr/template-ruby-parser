class Code
  class Parser
    class Call < ::Code::Parser
      def parse
        return if end_of_input?
        return if next?(SPECIAL) && !next?(AMPERSAND) && !next?(ASTERISK)
        return if next?(KEYWORDS)

        block = match(AMPERSAND) || nil

        if match(ASTERISK + ASTERISK)
          splat = :keyword
        elsif match(ASTERISK)
          splat = :regular
        else
          splat = nil
        end

        buffer!

        consume while !next?(SPECIAL) && !end_of_input?

        identifier = buffer!

        if match(OPENING_PARENTHESIS)
          arguments = []

          arguments << parse_argument

          arguments << parse_argument while match(COMMA) && !end_of_input?

          match(CLOSING_PARENTHESIS)
        else
          arguments = nil
        end

        consume while next?(WHITESPACE)

        if match(DO_KEYWORD)
          block_arguments, block_body = parse_block
          match(END_KEYWORD)
        elsif match(OPENING_CURLY_BRACKET)
          block_arguments, block_body = parse_block
          match(CLOSING_CURLY_BRACKET)
        else
          block_arguments, block_body = nil, nil
        end

        if arguments || block || splat || block_arguments || block_body
          {
            call: {
              name: identifier,
              arguments: arguments&.compact,
              splat: splat,
              block: block,
              block_arguments: block_arguments,
              block_body: block_body
            }.compact
          }
        else
          { call: identifier }
        end
      end

      private

      def parse_block
        consume while next?(WHITESPACE)

        if match(PIPE)
          arguments = []

          arguments << parse_argument

          arguments << parse_argument while match(COMMA) && !end_of_input?

          match(PIPE)

          [arguments, parse_code]
        else
          [nil, parse_code]
        end
      end

      def parse_argument
        previous_cursor = cursor
        key = parse_subclass(::Code::Parser::Statement)
        consume while next?(WHITESPACE)

        if match(COLON) || match(EQUAL + GREATER)
          value = parse_code
          { key: key, value: value }
        else
          buffer!
          @cursor = previous_cursor
          parse_code
        end
      end
    end
  end
end
