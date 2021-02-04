# frozen_string_literal: true

module Hubtrics
  # Parser handles setting up the command line switches most commonly used by the Hubtrics scripts, placing them nicely into a
  # structure object for use with configuration.
  class Parser
    require 'optparse'
    require 'yaml'

    attr_reader :options

    def initialize(banner:, program_name: nil)
      @options = {
        config: File.expand_path('../../.hubtrics.yml', __dir__),
        client: {},
        github: {},
        rules: {}
      }
      @banner = banner
      @program_name = program_name
    end

    def parse(args)
      parser = OptionParser.new do |opts|
        opts.banner = banner
        opts.program_name = program_name if program_name

        opts.on('-c CONFIG', '--config CONFIG', String, 'Path to config file') do |config|
          options[:config] = config
        end

        opts.on('--repository REPOSITORY', String, 'Repository to run this report against') do |repository|
          options[:repository] = repository
          options[:org], options[:repo] = repository.split('/')
        end

        opts.on(
          '--grace-period GRACE_PERIOD',
          Integer,
          'Grace period in days before considering the branch stale'
        ) do |grace_period|
          options[:grace_period] = grace_period
        end

        opts.on('--gist GIST', String, 'Update the Gist specified by the SHA provided') do |gist|
          options[:gist] = gist
        end

        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end
      end

      parser.parse!(args)

      config = YAML.load_file(options[:config])
      options[:client] = config.fetch(:client, {})
      options[:github] = config.fetch(:github, {})
      options[:rules] = config.fetch(:rules, {})

      options
    end

    private

    attr_reader :banner, :program_name
  end
end
