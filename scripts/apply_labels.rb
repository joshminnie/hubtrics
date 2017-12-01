#! /usr/bin/env ruby

require 'octokit'
require 'optparse'
require 'yaml'

require_relative '../lib/hubtrics'

options = { client: {} }
OptionParser.new do |opts|
  opts.banner = 'Usage: apply_labels.rb [options]'
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

  opts.on('--repository REPOSITORY', 'Repository for the pull requests') do |repository|
    options[:repository] = repository
  end

  opts.on('--dry-run', 'Runs through the process without making the changes') do |dry_run|
    options[:dry_run] = dry_run
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end.parse!

client = Hubtrics.client(options[:client])
pulls = client.pulls(options[:repository], state: 'open')
pulls.each do |pull|
  pull = Hubtrics::PullRequest.new(pull)

  # pull.number is issue number

  original_labels = client.labels_for_issue(pull.head.repo.full_name, pull.number).map(&:name).sort
  labels = original_labels.reject { |label| label =~ /^auto-tests-/ }

  labels <<
    case pull.state
    when 'passing' then 'auto-tests-passing'
    when 'failing' then 'auto-tests-failing'
    when 'pending' then 'auto-tests-in-progress'
    end

  next if original_labels == labels.sort

  if options[:dry_run]
    puts "Update #{pull.number} with #{labels}"
  else
    client.replace_all_labels(pull.head.repo.full_name, pull.number, labels)
    puts "Updated #{pull.number} with #{labels}"
  end
end
