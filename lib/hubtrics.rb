require 'octokit'
require 'yaml'
require 'virtus'

module Hubtrics
  require_relative 'hubtrics/pull_request'
  require_relative 'hubtrics/reports/pull_request_report'

  DIVIDER = '-' * 72

  # :reek:NilCheck { enabled: false }
  def self.client(options = {})
    options.delete_if { |_key, value| value.nil? }
    options = { auto_paginate: true }.merge(options)
    Octokit::Client.new(options)
  end

  def self.say(message)
    puts DIVIDER, message, DIVIDER
  end
end
