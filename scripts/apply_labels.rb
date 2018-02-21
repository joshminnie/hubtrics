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

  opts.on('--repository REPOSITORY', String, 'Repository to run this report against') do |repository|
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
pulls = client.pulls(options[:repository])

query = "repo:#{options[:repository]} is:open is:pr"

approved_pulls = client.search_issues("#{query} review:approved").items.map { |pull| Hubtrics::PullRequest.new(pull) }
rejected_pulls = client.search_issues("#{query} review:changes_requested").items.map { |pull| Hubtrics::PullRequest.new(pull) }

pulls.each do |pull|
  pull = Hubtrics::PullRequest.fetch(options[:repository], pull.number)

  original_labels = pull.labels
  labels = original_labels.dup

  labels << 'conflict-with-parent' if pull.mergeable == false

  labels = labels.reject { |label| label =~ /^auto-tests-/ }
  labels <<
    case pull.status
    when 'passing' then 'auto-tests-passing'
    when 'failing' then 'auto-tests-failing'
    when 'pending' then 'auto-tests-in-progress'
    end

  labels = labels.reject { |label| label =~ /^review-(approved|rejected)/ }
  labels <<
    if labels.include?('review-in-progress')
      nil
    elsif approved_pulls.include?(pull)
      'review-approved'
    elsif rejected_pulls.include?(pull)
      'review-rejected'
    end

  # Clean up the labels
  labels = labels.compact.sort.uniq

  next if original_labels == labels

  if options[:dry_run]
    puts "Update #{pull.number}: #{original_labels} with #{labels.sort}"
  else
    client.replace_all_labels(pull.repository, pull.number, labels)
    puts "Updated #{pull.number} with #{labels}"
  end
end
