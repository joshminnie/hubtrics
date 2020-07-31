module Hubtrics
  # Represents a branch from the GitHub API.
  #
  # @see https://developer.github.com/v3/repos/branches
  class Branch < Hubtrics::Base
    attribute :name, String
    attribute :protected, Boolean
    attribute :commit, Hubtrics::Commit
    attribute :author, Hubtrics::User
    attribute :last_commit, DateTime

    alias_method :protected?, :protected

    class << self
      # Fetches the pull request from the specified repository.
      #
      # @return [PullRequest] The pull request.
      def fetch(repository, branch_name)
        branch = Hubtrics.client.branch(repository, branch_name)
        new(branch)
      end
    end

    def initialize(*args)
      super
      @author = commit.author
      @last_commit = args.first.commit.commit.committer.date
    end
  end
end
