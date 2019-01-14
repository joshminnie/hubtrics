module Hubtrics
  # Represents a pull request from the GitHub API.
  #
  # @see https://developer.github.com/v3/pulls/
  class PullRequest < Hubtrics::Base
    attribute :id, Integer
    attribute :number, Integer
    attribute :repository, String
    attribute :sha, String
    attribute :title, String
    attribute :state, String
    attribute :status, String
    attribute :html_url, String
    attribute :mergeable, Boolean
    attribute :user, Hubtrics::User
    attribute :head, Hubtrics::Commit
    attribute :base, Hubtrics::Commit

    # Fetches the pull request from the specified repository.
    #
    # @return [PullRequest] The pull request.
    def self.fetch(repository, pull_number)
      pull = Hubtrics.client.pull(repository, pull_number)
      new(pull)
    end

    # Creates an instance of {PullRequest} using a +Sawyer::Resource+ received from the +Octokit+ gem.
    #
    # @return [Hubtrics::PullRequest] The new instance.
    # @note This is only intended to be initialized with a response from the +Octokit+ gem.
    def initialize(*args)
      super
      @status = nil
      @labels = nil
    end

    # Gets the combined status of continuous integration checks for the pull request.
    #
    # @return [String] The combined status of the continuous integration checks for the pull request.
    def status
      # Memoize it so we don't have to fetch it again
      @status ||= client.status(repository, head.sha).state

      case @status
      when 'failure' then 'failing'
      when 'success' then 'passing'
      else 'pending'
      end
    rescue StandardError
      nil
    end

    # Gets the name of the repository which is associated with the pull request resides.
    #
    # @return [String] The name of the repository which is associated with the pull request resides.
    def repository
      base.repo.full_name
    rescue StandardError
      nil
    end

    # Gets the list of labels currently applied to the pull request.
    #
    # @return [Array<String>] The list of labels currently applied to the pull request.
    def labels
      @labels ||= client.labels_for_issue(repository, number).map(&:name).sort
    end

    # Simple equality comparison for pull requests.
    #
    # @return [Boolean] +true+ if the pull requests are the same; +false+ otherwise.
    def ==(other)
      number == other.number
    end
  end
end
