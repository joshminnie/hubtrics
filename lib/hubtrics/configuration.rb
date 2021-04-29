module Hubtrics
  # :reek:Attribute { enabled: false }

  # Configuration class used to drive the main scripts.
  class Configuration
    # @!group Attributes

    # Configures the active organization.
    # Defaults to +nil+.
    # @param [String] value
    attr_accessor :organization

    # Configures the active repository.
    attr_accessor :repository

    # @!endgroup

    def initialize
      @organization = nil
      @repository = nil
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
