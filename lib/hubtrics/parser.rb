# frozen_string_literal: true

module Hubtrics
  # Parser handles setting up the command line switches most commonly used by the Hubtrics scripts, placing them nicely into a
  # structure object for use with configuration.
  class Parser
    require 'optparse'
    require 'yaml'

    attr_reader :options, :switches

    def initialize(banner:, program_name: nil, switches: [])
      @options = {
        config: File.expand_path('../../.hubtrics.yml', __dir__),
        client: {},
        github: {},
        rules: {}
      }
      @banner = banner
      @program_name = program_name
      @switches = switches
    end

    # :reek:NestedIterators
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

        # Includes dynamic switches that can be passed through from each command.
        switches.each do |switch|
          opts.on(*switch[:definition]) { |value| options[switch[:switch]] = value }
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
