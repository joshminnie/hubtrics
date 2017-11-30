module Hubtrics
  class User < Hubtrics::Base
    attribute :login, String
    attribute :html_url, String
  end
end
