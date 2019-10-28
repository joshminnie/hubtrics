module Hubtrics
  # Represents a repository from the GitHub API.
  #
  # @see https://developer.github.com/v3/users/
  class User < Hubtrics::Base
    attribute :login, String
    attribute :url, String
    attribute :date, DateTime

    # String representation of the {User}.
    #
    # @return [String] The string representation of the {User}.
    def to_s
      login
    end

    def html_url=(value)
      self.url = value
    end
  end
end
