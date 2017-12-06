require 'liquid'

module Hubtrics
  module Reports
    class PullRequestReport
      attr_reader :client

      attr_reader :report

      attr_reader :repository

      def initialize(client, repository)
        @client = client
        @repository = repository
      end

      def generate
        data = { 'conflicts' => [], 'failing' => [], 'pending' => [], 'passing' => [] }

        pulls = client.pulls(repository, state: 'open')
        pulls.each do |pull|
          pull = Hubtrics::PullRequest.fetch(repository, pull.number)

          data['conflicts'] << pull.to_h unless pull.mergeable
          data[pull.state] << pull.to_h
        end

        @report = template.render('data' => data, 'total_pulls' => pulls.count).strip
      end

      def save_to_gist(gist = nil)
        raise StandardError, 'Report was blank, so nothing was saved' if report.empty?

        options = {
          description: "Pull Requests Needing Review - #{Date.today}",
          public: false,
          files: { 'pull_requests.md' => { content: report } }
        }

        if gist
          client.edit_gist(gist, options)
        else
          client.create_gist(options)
        end
      end

      private

      def template
        @template ||= Liquid::Template.parse(File.read(File.expand_path('../templates/pull_request_report.md.liquid', __dir__)))
      end
    end
  end
end
