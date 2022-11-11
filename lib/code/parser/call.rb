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

        comments = parse_comments

        if match(DO_KEYWORD)
          block = parse_block
          match(END_KEYWORD)
        elsif match(OPENING_CURLY_BRACKET)
          block = parse_block
          match(CLOSING_CURLY_BRACKET)
        else
          block = nil
        end

        {
          call: {
            **identifier,
            arguments: arguments,
            block: block,
            comments: comments
          }.compact
        }
      end

      private

      def parse_block
        comments = parse_comments

        if match(PIPE)
          parameters = []

          parameters << (parse_keyword_parameter || parse_regular_parameter)

          while match(COMMA) && !end_of_input?
            parameters << (parse_keyword_parameter || parse_regular_parameter)
          end

          match(PIPE)

          {
            comments: comments,
            parameters: parameters.compact,
            body: parse_code
          }.compact
        else
          { comments: comments, body: parse_code }.compact
        end
      end

      def parse_keyword_argument
        previous_cursor = cursor

        comments_before = parse_comments
        key = parse_subclass(::Code::Parser::Statement)
        comments_after = parse_comments

        if key && match(COLON) || match(EQUAL + GREATER)
          default = parse_code
          default = nil if default.empty?
          {
            comments_before: comments_before,
            comments_after: comments_after,
            default: default,
            keyword: true,
            statement: key
          }.compact
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

        comments_before = parse_comments
        key = parse_subclass(::Code::Parser::Identifier)
        comments_after = parse_comments

        if key && match(COLON) || match(EQUAL + GREATER)
          default = parse_code
          default = nil if default.empty?
          {
            comments_before: comments_before,
            comments_after: comments_after,
            default: default,
            keyword: true,
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
        if identifier
          comments_after = parse_comments

          if match(EQUAL)
            default = parse_code
            default = nil if default.empty?

            {
              comments_before: comments_before,
              comments_after: comments_after,
              default: default,
              **identifier
            }.compact
          else
            {
              comments_before: comments_before,
              comments_after: comments_after,
              **identifier
            }.compact
          end
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end
    end
  end
end
