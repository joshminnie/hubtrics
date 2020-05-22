require 'liquid'

module Hubtrics
  module Reports
    class Base
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
        options = { description: title, public: false, files: files }

        if gist
          client.edit_gist(gist, options)
        else
          client.create_gist(options)
        end
      end

      private

      attr_reader :client, :repository, :data, :report, :config

      class << self
        def resolve_liquid_template(relative_path)
          Liquid::Template.parse(File.read(File.expand_path(relative_path, __dir__)))
        end
      end
    end
  end
end
