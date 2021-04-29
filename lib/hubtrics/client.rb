# frozen_string_literal: true

module Hubtrics
  # Wrapper class for the {Octokit::Client}.
  class Client
    # @return [Octokit::Client] The {Octokit::Client} which will make the requests against the GitHub API.
    # @see https://github.com/octokit/octokit.rb
    attr_reader :client

    # Configures the {Octokit::Client} necessary for making the requests against the GitHub API.
    # @param configuration [Hash] Configuration options for the {Octokit::Client}.
    # :reek:NilCheck { enabled: false }
    def initialize(configuration = {})
      configuration.delete_if { |_key, value| value.nil? }
      configuration = { auto_paginate: true }.merge(configuration)
      @client = Octokit::Client.new(configuration)
    end
  end

  def self.client
    return @client if defined?(@client)

    raise ''
  end
end

__END__

    return @client if defined?(@client)

    options.delete_if { |_key, value| value.nil? }
    options = { auto_paginate: true }.merge(options)
    @client = Octokit::Client.new(options)
