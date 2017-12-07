require 'liquid'

module Hubtrics
  module Reports
    class PullRequestReport
      # Creates an instance of the {PullRequestReport}.
      def initialize(client, repository)
        @client = client
        @repository = repository
      end

      # Generates the report content.
      # @return [String] The content for the report.
      def generate
        data = { 'conflicts' => [], 'failing' => [], 'pending' => [], 'passing' => [] }

        pulls = client.pulls(repository)
        pulls.each do |pull|
          pull = Hubtrics::PullRequest.fetch(repository, pull.number)

          # pull.mergeable contains a nil when the check has not been performed yet, so we need to compare against false
          data['conflicts'] << pull.to_h if pull.mergeable == false
          data[pull.status] << pull.to_h
        end

        @report = template.render('data' => data, 'total_pulls' => pulls.count).strip
      end

      # Writes the report to a gist, updating if the gist SHA was provided.
      # @param gist [String] The SHA of the gist to update.
      # @return [Sawyer::Resource] Gist info.
      def save_to_gist(gist = nil)
        raise StandardError, 'Report was blank, so nothing was saved' if report.empty?

        options = {
          description: "Hubtrics: Pull Requests Metrics for #{Date.today}",
          public: false,
          files: { 'metrics.md' => { content: report } }
        }

        if gist
          client.edit_gist(gist, options)
        else
          client.create_gist(options)
        end
      end

      private

      attr_reader :client

      attr_reader :report

      attr_reader :repository

      # Gets the template for the metrics report.
      # @return [Liquid::Template] The {Liquid::Template} which can be used to render the report.
      def template
        @template ||= Liquid::Template.parse(File.read(File.expand_path('../templates/pull_request_report.md.liquid', __dir__)))
      end
    end
  end
end
