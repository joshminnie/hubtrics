# frozen_string_literal: true

module Hubtrics
  # Represents a repository from the GitHub API.
  #
  # @see https://developer.github.com/v3/repos/
  class Repository < Hubtrics::Base
    attribute :name, String
    attribute :full_name, String
    attribute :description, String
  end
end
