require 'liquid'

module Hubtrics
  module Reports
    class ClosedPullReport < Hubtrics::Reports::Base
      # Generates the report content.
      #
      # @return [String] The content for the report.
      def generate
        query = "repo:#{repository} is:closed is:pr closed:>#{Date.today.prev_year}"
        searched_pulls = client.search_issues(query).items
        data = searched_pulls.map { |pull| Hubtrics::PullRequest.new(pull).to_h }

        @report = template.render(
          'data' => data,
          'total_pulls' => searched_pulls.count,
          'closed_date' => Date.today.prev_year
        ).strip
      end

      private

      # Gets the template for the metrics report.
      #
      # @return [Liquid::Template] The {Liquid::Template} which can be used to render the report.
      def template
        @template ||= Liquid::Template.parse(File.read(File.expand_path('../templates/closed_pull_report.md.liquid', __dir__)))
      end

      # Gets the report title.
      #
      # @return [String] The report title.
      def title
        "Hubtrics: Closed Pull Requests for #{Date.today}"
      end

      # Gets the files for the Gist.
      #
      # @return [Hash] The file hash for the Gist.
      def files
        { 'closed_pulls.md' => { content: report } }
      end
    end
  end
end
