class Code
  class Parser
    class Call < ::Code::Parser
      def parse
        identifier = parse_subclass(::Code::Parser::Identifier)
        return unless identifier

        if match(OPENING_PARENTHESIS)
          arguments = []

          arguments << (parse_keyword_argument || parse_regular_argument)

          while match(COMMA) && !end_of_input?
            arguments << (parse_keyword_argument || parse_regular_argument)
          end

          arguments.compact!

          match(CLOSING_PARENTHESIS)
        else
          arguments = nil
        end

        consume while next?(WHITESPACE)

        if match(DO_KEYWORD)
          block_parameters, block_body = parse_block
          match(END_KEYWORD)
        elsif match(OPENING_CURLY_BRACKET)
          block_parameters, block_body = parse_block
          match(CLOSING_CURLY_BRACKET)
        else
          block_parameters, block_body = nil, nil
        end

        if identifier[:block].nil? && identifier[:splat].nil? && !arguments &&
             !block_parameters && !block_body
          { call: identifier[:name] }
        else
          {
            call: {
              **identifier,
              arguments: arguments,
              block_parameters: block_parameters,
              block_body: block_body
            }.compact
          }
        end
      end

      private

      def parse_block
        consume while next?(WHITESPACE)

        if match(PIPE)
          parameters = []

          consume while next?(WHITESPACE)
          parameters << (parse_keyword_parameter || parse_regular_parameter)

          while match(COMMA) && !end_of_input?
            consume while next?(WHITESPACE)
            parameters << (parse_keyword_parameter || parse_regular_parameter)
          end

          match(PIPE)

          [parameters.compact, parse_code]
        else
          [nil, parse_code]
        end
      end

      def parse_keyword_argument
        previous_cursor = cursor

        key = parse_subclass(::Code::Parser::Statement)
        consume while next?(WHITESPACE)

        if key && match(COLON) || match(EQUAL + GREATER)
          default = parse_code
          default = nil if default.empty?
          { default: default, keyword: true, statement: key }
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end

      def parse_regular_argument
        code = parse_code
        return if code.empty?
        code
      end

      def parse_keyword_parameter
        previous_cursor = cursor

        key = parse_subclass(::Code::Parser::Identifier)
        consume while next?(WHITESPACE)

        if key && match(COLON) || match(EQUAL + GREATER)
          default = parse_code
          default = nil if default.empty?
          { default: default, keyword: true, **key }
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end

      def parse_regular_parameter
        identifier = parse_subclass(::Code::Parser::Identifier)
        return unless identifier

        consume while next?(WHITESPACE)

        if match(EQUAL)
          default = parse_code
          default = nil if default.empty?

          { default: default, **identifier }
        else
          identifier
        end
      end
    end
  end
end
