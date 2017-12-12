require 'liquid'

module Hubtrics
  module Reports
    class PullRequestReport < Hubtrics::Reports::Base
      # Generates the report content.
      #
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

      private

      # Gets the template for the metrics report.
      #
      # @return [Liquid::Template] The {Liquid::Template} which can be used to render the report.
      def template
        @template ||= Liquid::Template.parse(File.read(File.expand_path('../templates/pull_request_report.md.liquid', __dir__)))
      end

      # Gets the report title.
      #
      # @return [String] The report title.
      def title
        "Hubtrics: Pull Requests Metrics for #{Date.today}"
      end

      # Gets the files for the Gist.
      #
      # @return [Hash] The file hash for the Gist.
      def files
        { 'metrics.md' => { content: report } }
      end
    end
  end
end
