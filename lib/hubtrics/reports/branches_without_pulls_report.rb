require 'liquid'

module Hubtrics
  module Reports
    # Generates a report showing how many branches without pull requests exist on the repository. This is helpful to call out to
    # those developers who started those branches to see them through to the end of the development process and keep your
    # repository clean.
    class BranchesWithoutPullsReport < Hubtrics::Reports::Base
      def generate
        branches = client.branches(repository, protected: false)

        branches_without_pulls = {}

        branches.each do |branch|
          branch = Hubtrics::Branch.fetch(repository, branch.name)
          print '.'
          next if ignore_branch?(branch)

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

        @data = {
          'data' => branches_without_pulls.sort_by { |_, v| -v.size },
          'repository' => repository,
          'total_branches' => branches.count,
          'total_branches_without_pulls' => branches_without_pulls.reduce(0) { |sum, (_key, value)| sum + value.count }
        }
      rescue Octokit::InternalServerError => e
        puts '', 'Unable to finish request, GitHub responded with an error', e.message
      end

      private

      # Gets the template for the metrics report.
      #
      # @return [Liquid::Template] The {Liquid::Template} which can be used to render the report.
      def template
        @template ||= {
          markdown: self.class.resolve_liquid_template('../templates/branches_without_pulls.md.liquid'),
          csv: self.class.resolve_liquid_template('../templates/branches_without_pulls.csv.liquid')
        }
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
        {
          '1-branches_without_pulls.md' => { content: template[:markdown].render(data).strip },
          '2-branches_without_pulls.csv' => { content: template[:csv].render(data).strip }
        }
      end

      def organization
        organization, = repository.split('/')
        organization
      end

      # :reek:FeatureEnvy
      def ignore_branch?(branch)
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
