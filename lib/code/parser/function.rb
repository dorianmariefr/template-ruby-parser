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
        return if end_of_input?
        return if next?(SPECIAL) && !next?(AMPERSAND) && !next?(ASTERISK)
        return if next?(KEYWORDS)

        previous_cursor = cursor

        buffer!

        consume while !next?(SPECIAL) && !end_of_input?

        key = buffer!

        consume while next?(WHITESPACE)

        if match(COLON) || match(EQUAL + GREATER)
          default = parse_code

          default = nil if default.empty?

          { name: key, default: default, keyword: true }.compact
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end

      def parse_regular_parameter
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

        consume while next?(WHITESPACE)

        if match(EQUAL)
          default = parse_code
        else
          default = nil
        end

        {
          name: identifier,
          splat: splat,
          block: block,
          default: default
        }.compact
      end
    end
  end
end
