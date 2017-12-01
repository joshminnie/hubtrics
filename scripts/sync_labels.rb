#! /usr/bin/env ruby

require 'octokit'
require 'optparse'
require 'yaml'
require 'csv'

require_relative '../lib/hubtrics'

options = { client: {} }
OptionParser.new do |opts|
  opts.banner = 'Usage: sync_labels.rb [options]'
  opts.program_name = 'Hubtrics: GitHub-based reports and metrics'

  # -----------------------------------------------------------------------------
  # BEGIN Authentication options

  options[:config] = File.expand_path('../config/secrets.yml', __dir__)
  opts.on('-c CONFIG', '--config CONFIG', String, 'Path to config file') do |config|
    options[:config] = config
  end

  config = YAML.load_file(options[:config]).fetch('client', {})

  options[:client][:login] = config.fetch('login', nil)
  opts.on('--login LOGIN', String, 'Login for your GitHub account') do |login|
    options[:client][:login] = login
  end

  options[:client][:access_token] = config.fetch('access_token', nil)
  opts.on('--access-token TOKEN', String, 'OAuth access token for your GitHub account') do |token|
    options[:client][:access_token] = token
  end

  options[:client][:netrc] = config.fetch('netrc', false)
  opts.on('--[no-]netrc', 'Use .netrc to connect') do |netrc|
    options[:client][:netrc] = netrc
  end

  # END Authentication option
  # -----------------------------------------------------------------------------

  opts.on('--source REPOSITORY', 'Repository to copy labels from') do |repository|
    options[:source] = repository
  end

  opts.on('--destination REPOSITORY', 'Repository to copy labels to') do |repository|
    options[:destination] = repository
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end.parse!

client = Hubtrics.client(options[:client])

source_labels = client.labels(options[:source])
source_labels.each do |label|
  begin
    client.update_label(options[:destination], label.name, color: label.color)
    puts "#{label.name} updated with color ##{label.color}"
  rescue Octokit::NotFound
    client.add_label(options[:destination], label.name, label.color)
    puts "#{label.name} created with color ##{label.color}"
  end
end

destination_labels = client.labels(options[:destination])
destination_labels.each do |label|
  unless source_labels.map(&:name).include?(label.name)
    client.delete_label!(options[:destination], label.name)
    puts "#{label.name} was removed"
  end
end
