require 'liquid'

module Hubtrics
  module Reports
    class PullRequestReport < Hubtrics::Reports::Base
      SEARCH_QUERY = 'is:open is:pr review:approved label:auto-tests-passing label:review-approved'.freeze

      # Generates the report content.
      #
      # @return [String] The content for the report.
      def generate
        searched_pulls = client.search_issues("repo:#{repository} #{SEARCH_QUERY}").items
        @data = {
          'data' => searched_pulls.map { |pull| Hubtrics::PullRequest.fetch(repository, pull.number).to_h },
          'total_pulls' => searched_pulls.count
        }
      end

      private

      # Gets the template for the metrics report.
      #
      # @return [Liquid::Template] The {Liquid::Template} which can be used to render the report.
      def template
        @template ||= {
          markdown: Liquid::Template.parse(File.read(File.expand_path('../templates/pull_requests_report.md.liquid', __dir__))),
          csv: Liquid::Template.parse(File.read(File.expand_path('../templates/pull_requests_report.csv.liquid', __dir__)))
        }
      end

      # Gets the report title.
      #
      # @return [String] The report title.
      def title
        "Hubtrics: Pull Request Report for #{Date.today}"
      end

      # Gets the files for the Gist.
      #
      # @return [Hash] The file hash for the Gist.
      def files
        {
          '1-pulls.md' => { content: template[:markdown].render(data) },
          '2-pulls.csv' => { content: template[:csv].render(data) }
        }
      end
    end
  end
end
