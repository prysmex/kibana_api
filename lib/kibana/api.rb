require_relative 'api/base_client'
require_relative 'api/spaceable'
require_relative 'api/namespace/canvas'
require_relative 'api/namespace/features'
require_relative 'api/namespace/role'
require_relative 'api/namespace/saved_object'
require_relative 'api/namespace/space'

module Kibana
  module API

    class << self
      attr_accessor :client
    end

    def self.included(base)
      base.send :include,
                Kibana::API::Features,
                Kibana::API::Role,
                Kibana::API::SavedObject,
                Kibana::API::Space,
                Kibana::API::Canvas
    end

  end
end