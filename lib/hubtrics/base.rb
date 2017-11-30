module Hubtrics
  class Base
    include Virtus.model

    attribute :client, Octokit::Client

    def client
      @client ||= Hubtrics.client
    end
  end
end
