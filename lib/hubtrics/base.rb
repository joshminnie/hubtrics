module Hubtrics
  class Base
    send(:include, Virtus.model)

    attribute :client, Octokit::Client

    def client
      @client ||= Hubtrics.client
    end

    # Converts the attributes to a shallow string-keyed hash.
    # @return [Hash] The converted hash with string keys and values.
    def to_h
      attributes.each_with_object({}) { |(key, value), hash| hash[key.to_s] = value.to_s }
    end
  end
end
