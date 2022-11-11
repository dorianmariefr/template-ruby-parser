class Code
  class Parser
    class Comments < ::Code::Parser
      def parse
        comments = []

        while next?(WHITESPACE) || next?(SLASH + SLASH) ||
                next?(SLASH + ASTERISK) || next?(HASH)
          consume while next?(WHITESPACE)
          buffer!

          if match(SLASH + SLASH) || match(HASH)
            consume while !next?(NEWLINE) && !end_of_input?
            match(NEWLINE)
            comments << buffer
          end

          consume while next?(WHITESPACE)
          buffer!

          if match(SLASH + ASTERISK)
            consume while !next?(ASTERISK + SLASH) && !end_of_input?
            match(ASTERISK + SLASH)
            comments << buffer
          end
        end

        comments.empty? ? nil : comments
      end
    end
  end
end
