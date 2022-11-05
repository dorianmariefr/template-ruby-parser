class Code
  class Parser
    class Call < ::Code::Parser
      def parse
        if next?(AMPERSAND) || next?(ASTERISK) || !next?(SPECIAL)
          block = match(AMPERSAND) || nil

          if match(ASTERISK + ASTERISK)
            splat = :keyword
          elsif match(ASTERISK)
            splat = :regular
          else
            splat = nil
          end

          string = match(COLON) || nil

          @start = current
          advance while !next?(SPECIAL) && !end_of_input?

          identifier = input[start...current]

          if NOTHING_KEYWORDS.include?(identifier)
            { nothing: identifier }
          elsif BOOLEAN_KEYWORDS.include?(identifier)
            { boolean: identifier }
          elsif identifier == END_KEYWORD
            @current = start
            nil
          else
            if match(OPENING_PARENTHESIS)
              arguments = []
              code = parse_code

              arguments << code if code.any?

              while next?(COMMA) && !end_of_input?
                advance

                code = parse_code
                arguments << code if code.any?
              end

              match(CLOSING_PARENTHESIS)
            else
              arguments = nil
            end

            @start = current

            advance while next?(SPACE) || next?(NEWLINE)

            if match(DO_KEYWORD)
              advance while next?(SPACE) || next?(NEWLINE)

              if match(PIPE)
                block_arguments = []

                code = parse_code
                block_arguments << code if code.any?

                while next?(COMMA) && !end_of_input?
                  advance

                  code = parse_code
                  block_arguments << code if code.any?
                end

                match(PIPE)

                block_body = parse_code

                match(END_KEYWORD)
              else
                block_arguments = nil
                block_body = parse_code

                match(END_KEYWORD)
              end
            elsif match(OPENING_CURLY_BRACKET)
              advance while next?(SPACE) || next?(NEWLINE)

              if match(PIPE)
                block_arguments = []

                code = parse_code
                block_arguments << code if code.any?

                while next?(COMMA) && !end_of_input?
                  advance

                  code = parse_code
                  block_arguments << code if code.any?
                end

                match(PIPE)

                block_body = parse_code

                match(CLOSING_CURLY_BRACKET)
              else
                block_arguments = nil
                block_body = parse_code

                match(CLOSING_CURLY_BRACKET)
              end
            else
              @current = start
            end

            if arguments || block_arguments || block_body
              if block_arguments || block_body
                {
                  call: {
                    name: identifier,
                    arguments: arguments&.empty? ? nil : arguments,
                    block: {
                      arguments: block_arguments,
                      body: block_body.compact
                    }.compact
                  }.compact
                }
              else
                {
                  call: {
                    name: identifier,
                    arguments: arguments&.empty? ? nil : arguments
                  }.compact
                }
              end
            else
              if block || splat || string
                {
                  variable: {
                    name: identifier,
                    block: block,
                    splat: splat,
                    string: string
                  }.compact
                }
              else
                { variable: identifier }
              end
            end
          end
        else
          parse_subclass(::Code::Parser::Group)
        end
      end

      private

      attr_reader :block, :splat
    end
  end
end
