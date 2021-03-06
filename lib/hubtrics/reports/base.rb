# frozen_string_literal: true

require 'liquid'

# :reek:UnusedParameters
# rubocop:disable Lint/UnusedMethodArgument
module Hubtrics
  module Reports
    # Base class for all reports.
    class Base
      class << self
        def render(client:, repository:, config:, options: {})
          raise NotImplementedError, 'This method has not been implemented by the inheriting class.'
        end
      end

      # Creates an instance of the {Base}.
      def initialize(client, repository:, config:, options: {})
        @client = client
        @repository = repository
        @config = config
        @options = options
      end

      # Writes the report to a gist, updating if the gist SHA was provided.
      #
      # @param gist [String] The SHA of the gist to update.
      # @return [Sawyer::Resource] Gist info.
      def save_to_gist(gist = nil)
        gist_options = { description: title, public: false, files: files }

        if gist
          client.edit_gist(gist, gist_options)
        else
          client.create_gist(gist_options)
        end
      end

      private

      attr_reader :client, :repository, :data, :report, :config, :options

      class << self
        def resolve_liquid_template(relative_path)
          Liquid::Template.parse(File.read(File.expand_path(relative_path, __dir__)))
        end
      end
    end
  end
end
# rubocop:enable Lint/UnusedMethodArgument
