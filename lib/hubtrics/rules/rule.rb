module Hubtrics
  module Rules
    class Rule
      attr_reader :rule

      def initialize(rule)
        @rule =
          if rule.start_with?('/') && rule.end_with?('/')
            # Remove the leading and trailing characters that signify it's a regexp.
            Regexp.new(rule.gsub(/\A\/|\/\Z/, ''))
          else
            rule
          end
      end

      def valid?(value)
        if rule.is_a?(Regexp)
          rule.match?(value)
        else
          rule == value
        end
      end
    end
  end
end
