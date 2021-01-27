module Hubtrics
  class Parser
    require 'optparse'
    require 'yaml'

    attr_reader :options

    def initialize
      @options = {
        config: File.expand_path('../../.hubtrics.yml', __dir__),
        client: {},
        github: {}
      }
    end

    def parse(args)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: metrics [options]'
        opts.program_name = 'Hubtrics: GitHub-based reports and metrics'

        opts.on('-c CONFIG', '--config CONFIG', String, 'Path to config file') do |config|
          options[:config] = config
        end

        opts.on('--repository REPOSITORY', String, 'Repository to run this report against') do |repository|
          options[:repository] = repository
          options[:org], options[:repo] = repository.split('/')
        end

        opts.on('--grace-period GRACE_PERIOD', Integer, 'Grace period in days before considering the branch stale') do |grace_period|
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

      options
    end
  end
end
