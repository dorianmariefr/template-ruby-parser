class Code
  class Parser
    class Function < ::Code::Parser
      def parse
        return parse_next unless next?(OPENING_PARENTHESIS)
        previous_cursor = cursor
        match(OPENING_PARENTHESIS)
        parameters_comments = parse_comments
        parameters = parse_parameters
        match(CLOSING_PARENTHESIS)
        comments_before = parse_comments
        if match(EQUAL + GREATER)
          comments_after = parse_comments
          if match(OPENING_CURLY_BRACKET)
            body = parse_code
            match(CLOSING_CURLY_BRACKET)
            {
              function: {
                parameters: parameters,
                body: body,
                parameters_comments: parameters_comments,
                comments_before: comments_before,
                comments_after: comments_after
              }.compact
            }
          else
            buffer!
            @cursor = previous_cursor
            parse_next
          end
        else
          buffer!
          @cursor = previous_cursor
          parse_next
        end
      end

      def parse_next
        parse_subclass(::Code::Parser::ChainedCall)
      end

      def parse_parameters
        parameters = []

        parameters << (parse_keyword_parameter || parse_regular_parameter)

        while match(COMMA) && !end_of_input?
          parameters << (parse_keyword_parameter || parse_regular_parameter)
        end

        parameters.compact.empty? ? nil : parameters.compact
      end

      def parse_keyword_parameter
        previous_cursor = cursor

        comments_before = parse_comments

        key = parse_subclass(::Code::Parser::Identifier)

        comments_after = parse_comments

        if key && (match(COLON) || match(EQUAL + GREATER))
          default = parse_code

          {
            default: default,
            keyword: true,
            comments_before: comments_before,
            comments_after: comments_after,
            **key
          }.compact
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end

      def parse_regular_parameter
        previous_cursor = cursor
        comments_before = parse_comments

        identifier = parse_subclass(::Code::Parser::Identifier)

        comments_after = parse_comments

        if identifier
          if match(EQUAL)
            default = parse_code
          else
            default = nil
          end

          {
            default: default,
            comments_before: comments_before,
            comments_after: comments_after,
            **identifier
          }.compact
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end
    end
  end
end
