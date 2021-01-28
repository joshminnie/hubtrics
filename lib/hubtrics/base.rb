# frozen_string_literal: true

module Hubtrics
  # Represents the basis for all {Hubtrics} models.
  class Base
    send(:include, Virtus.model)

    attribute :client, Octokit::Client

    # Converts the attributes to a shallow string-keyed hash.
    #
    # @return [Hash] The converted hash with string keys and values.
    def to_h
      attributes.each_with_object({}) { |(key, value), hash| hash[key.to_s] = value.to_s }
    end

    protected

    # Gets the {Octokit::Client} to make requests against the GitHub API.
    #
    # @return [Octokit::Client] The {Octokit::Client} to make requests against the GitHub API.
    def client
      @client ||= Hubtrics.client
    end
  end
end
