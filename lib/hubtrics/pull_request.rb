module Hubtrics
  class PullRequest < Hubtrics::Base
    attribute :id, Integer
    attribute :number, Integer
    attribute :repository, String
    attribute :sha, String
    attribute :title, String
    attribute :state, String
    attribute :html_url, String
    attribute :mergeable, Boolean
    attribute :user, Hubtrics::User
    attribute :head, Hubtrics::Commit
    attribute :base, Hubtrics::Commit

    def self.fetch(repository, pull_number)
      pull = Hubtrics.client.pull(repository, pull_number)
      new(pull)
    end

    # Creates an instance of {Hubtric::PullRequest} using a +Sawyer::Resource+ received from the +Octokit+ gem.
    # @return [Hubtrics::PullRequest] The new instance.
    # @note This is only intended to be initialized with a response from the +Octokit+ gem.
    def initialize(*args)
      super
      @state = client.status(head.repo.full_name, head.sha).state
      @repository = head.repo.full_name
    end

    def state
      case super
      when 'failure' then 'failing'
      when 'success' then 'passing'
      else 'pending'
      end
    end
  end
end
