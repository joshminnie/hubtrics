#! /usr/bin/env ruby

require 'octokit'
require 'optparse'
require 'yaml'

require_relative '../lib/hubtrics'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: pull_requests_report.rb [options]'
  opts.program_name = 'Hubtrics: GitHub-based reports and metrics'

  opts.on('-r REPO', '--repository REPO', 'Repository to run this report against') do |repository|
    options[:repository] = repository
  end

  opts.on('-g GIST', '--gist GIST', String, 'Update the Gist specified by the SHA provided') do |gist|
    options[:gist] = gist
  end

  options[:config] = File.expand_path('../config/secrets.yml', __dir__)
  opts.on('-c CONFIG', '--config CONFIG', String, 'Path to overriding config file') do |config|
    options[:config] = config
  end

  options[:netrc] = false
  opts.on('--[no-]netrc', 'Use .netrc to connect') do |netrc|
    options[:netrc] = netrc
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end.parse!

p options
