require 'liquid'

module Hubtrics
  module Reports
    class BranchesWithoutPullsReport < Hubtrics::Reports::Base
      def generate
        branches = client.branches(repository, protected: false)

        branches_without_pulls = {}

        branches.each do |branch|
          branch = Hubtrics::Branch.fetch(repository, branch.name)
          print '.'
          next if branch.protected? || branch.last_commit > (Date.today - 14).to_time.utc || ignore_branch?(branch: branch)

          pulls = client.pulls(repository, head: "#{organization}:#{branch.name}", state: 'open')
          next unless pulls.count < 1

          author = branch.author
          branches_without_pulls[author.login] ||= []
          branches_without_pulls[author.login] << branch.to_h.merge(
            'author' => author.login,
            'profile' => author.url
          )
        end

        puts ''

        @report = template.render(
          'data' => branches_without_pulls,
          'repository' => repository,
          'total_branches' => branches.count,
          'total_branches_without_pulls' => branches_without_pulls.reduce(0) { |sum, (_key, value)| sum + value.count }
        ).strip
      rescue Octokit::InternalServerError => e
        puts e.message
      end

      private

      # Gets the template for the metrics report.
      #
      # @return [Liquid::Template] The {Liquid::Template} which can be used to render the report.
      def template
        @template ||= Liquid::Template.parse(
          File.read(File.expand_path('../templates/branches_without_pulls.md.liquid', __dir__))
        )
      end

      # Gets the report title.
      #
      # @return [String] The report title.
      def title
        "Hubtrics: Branches without Pulls #{Date.today}"
      end

      # Gets the files for the Gist.
      #
      # @return [Hash] The file hash for the Gist.
      def files
        { 'branches_without_pulls.md' => { content: report } }
      end

      def organization
        organization, = repository.split('/')
        organization
      end

      # :reek:FeatureEnvy
      def ignore_branch?(branch:)
        ignored_branches = [config.dig('branches', 'protected'), config.dig('branches', 'exclude')].flatten.compact

        if branch.protected? || branch.last_commit > (Date.today - 14).to_time.utc || ignored_branches.include?(branch.name)
          return true
        end

        ignored_branches.any? do |ignored|
          if ignored.start_with?('/') && ignored.end_with?('/')
            # Remove the leading and trailing characters that signify it's a regexp and then compare.
            Regexp.new(ignored.gsub(/\A\/|\/\Z/, '')).match?(branch.name)
          else
            ignored == branch.name
          end
        end
      end
    end
  end
end
