module Hubtrics
  class Commit < Hubtrics::Base
    attribute :ref, String
    attribute :sha, String
    attribute :repo, Hubtrics::Repository

    def to_s
      ref
    end
  end
end
