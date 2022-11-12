class Code
  class Parser
    class Operation < ::Code::Parser
      def initialize(input, operators:, subclass:, **kargs)
        super(input, **kargs)

        @operators = operators
        @subclass = subclass
      end

      def parse
        previous_cursor = cursor
        left = parse_subclass(subclass)
        if left
          right = []
          previous_cursor = cursor
          comments = parse_comments

          while operator = match(operators)
            comments = parse_comments
            statement = parse_subclass(subclass)
            right << {
              comments: comments,
              statement: statement,
              operator: operator
            }.compact
          end

          if right.empty?
            @cursor = previous_cursor
            buffer!
            left
          else
            {
              operation: {
                left: left,
                comments: comments,
                right: right
              }.compact
            }
          end
        else
          @cursor = previous_cursor
          buffer!
          return
        end
      end

      private

      attr_reader :operators, :subclass
    end
  end
end
