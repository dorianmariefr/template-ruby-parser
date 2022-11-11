class Code
  class Parser
    class Function < ::Code::Parser
      def parse
        return parse_chained_call unless next?(OPENING_PARENTHESIS)
        previous_cursor = cursor
        match(OPENING_PARENTHESIS)
        parameters = parse_parameters
        match(CLOSING_PARENTHESIS)
        consume while next?(WHITESPACE)
        if match(EQUAL + GREATER)
          consume while next?(WHITESPACE)
          if match(OPENING_CURLY_BRACKET)
            body = parse_code
            match(CLOSING_CURLY_BRACKET)
            { function: { parameters: parameters, body: body }.compact }
          else
            buffer!
            @cursor = previous_cursor
            parse_chained_call
          end
        else
          buffer!
          @cursor = previous_cursor
          parse_chained_call
        end
      end

      def parse_chained_call
        parse_subclass(::Code::Parser::ChainedCall)
      end

      def parse_parameters
        parameters = []

        consume while next?(WHITESPACE)
        parameters << (parse_keyword_parameter || parse_regular_parameter)
        consume while next?(WHITESPACE)

        while match(COMMA) && !end_of_input?
          consume while next?(WHITESPACE)
          parameters << (parse_keyword_parameter || parse_regular_parameter)
          consume while next?(WHITESPACE)
        end

        parameters.compact.empty? ? nil : parameters.compact
      end

      def parse_keyword_parameter
        previous_cursor = cursor

        key = parse_subclass(::Code::Parser::Identifier)

        consume while next?(WHITESPACE)

        if key && (match(COLON) || match(EQUAL + GREATER))
          default = parse_code

          default = nil if default.empty?

          { default: default, keyword: true, **key }.compact
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end

      def parse_regular_parameter
        identifier = parse_subclass(::Code::Parser::Identifier)
        return if !identifier

        consume while next?(WHITESPACE)

        if match(EQUAL)
          default = parse_code
        else
          default = nil
        end

        { default: default, **identifier }.compact
      end
    end
  end
end
