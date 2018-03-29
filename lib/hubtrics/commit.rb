module Hubtrics
  # Represents a commit from the GitHub API.
  #
  # @see https://developer.github.com/v3/repos/commits/
  class Commit < Hubtrics::Base
    attribute :ref, String
    attribute :sha, String
    attribute :repo, Hubtrics::Repository
    attribute :author, Hubtrics::User
    attribute :committer, Hash
    attribute :date, DateTime

    # String representation of the {Commit}.
    #
    # @return [String] The string representation of the {Commit}.
    def to_s
      ref
    end
  end
end
