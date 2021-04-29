# frozen_string_literal: true

module Hubtrics
  require 'hashie'

  # Structured representation of a GitHub label.
  class Label < Hashie::Dash
    # include Hashie::Extensions::Coercion
    # include Hashie::Extensions::MergeInitializer
    # include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Dash::Coercion

    property :name, required: true
    property :color, default: '#cccccc', coerce: ->(v) { v.to_s.downcase }
    property :enabled, default: true
    property :description

    # alias_method :enabled?, :enabled
  end
end
