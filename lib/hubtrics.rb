require 'octokit'
require 'yaml'
require 'virtus'

module Hubtrics
  require_relative 'hubtrics/base'
  require_relative 'hubtrics/user'
  require_relative 'hubtrics/repository'
  require_relative 'hubtrics/commit'
  require_relative 'hubtrics/pull_request'
  require_relative 'hubtrics/reports/pull_request_report'

  DIVIDER = '-' * 72

  # :reek:NilCheck { enabled: false }
  def self.client(options = {})
    return @client if defined?(@client)
    options.delete_if { |_key, value| value.nil? }
    options = { auto_paginate: true }.merge(options)
    @client = Octokit::Client.new(options)
  end

  # Renders a message to STDOUT wrapped with the {DIVIDER}.
  # @param message [String] Message to render.
  # @return [void]
  def self.say(message)
    puts DIVIDER, message, DIVIDER
  end
end
