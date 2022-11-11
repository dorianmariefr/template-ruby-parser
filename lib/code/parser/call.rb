class Code
  class Parser
    class Call < ::Code::Parser
      def parse
        identifier = parse_subclass(::Code::Parser::Identifier)
        return unless identifier

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

        if identifier[:block].nil? && identifier[:splat].nil? && !arguments &&
             !block_arguments && !block_body
          { call: identifier[:name] }
        else
          {
            call: {
              **identifier,
              arguments: arguments&.compact,
              block_arguments: block_arguments,
              block_body: block_body
            }.compact
          }
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
