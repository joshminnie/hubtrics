module Hubtrics
  module Reports
    class PullRequestReport
      attr_reader :client

      attr_reader :content

      attr_reader :repository

      def initialize(client, repository)
        @client = client
        @repository = repository
        @content = ''
      end

      def generate
        @content = '' # reset the content

        status = {}
        conflicts = []

        pulls = client.pulls(repository, state: 'open')
        pulls.each do |pull|
          pull = Hubtrics::PullRequest.fetch(repository, pull.number)

          conflicts << pull unless pull.mergeable

          status[pull.state] ||= []
          status[pull.state] << pull
        end

        @content += "# #{conflicts.count} of #{pulls.count} pulls have conflicts with their base branch:\n"
        conflicts.each { |pull| @content += "- #{pull.to_markdown}\n" }

        status.each_key do |key|
          list = status[key].compact
          next if list.empty?

          @content += "# #{list.count} of #{pulls.count} pulls are #{key} CI:\n"
          list.each { |pull| @content += "- #{pull.to_markdown}\n" }
        end

        @content
      end

      def save_to_gist(gist = nil)
        raise StandardError, 'Report was blank, so nothing was saved' if content.empty?

        options = {
          description: "Pull Requests Needing Review - #{Date.today}",
          public: false,
          files: { 'pull_requests.md' => { content: content } }
        }

        if gist
          client.edit_gist(gist, options)
        else
          client.create_gist(options)
        end
      end
    end
  end
end
