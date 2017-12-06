module Hubtrics
  class User < Hubtrics::Base
    attribute :login, String
    attribute :html_url, String

    def to_s
      login
    end
  end
end
