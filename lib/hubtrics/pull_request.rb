module Hubtrics
  class PullRequest
    include Virtus.model

    attribute :id, Integer
    attribute :title, String
    attribute :state, String
    attribute :html_url, String
    attribute :mergeable, Boolean
    attribute :user, Hash

    def to_markdown
      "[#{title}](#{html_url}) - [@#{user[:login]}](#{user[:html_url]})"
    end
  end
end
