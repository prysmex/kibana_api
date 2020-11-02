require_relative 'api/base_client'
require_relative 'api/spaceable'
require_relative 'api/namespace/features'
require_relative 'api/namespace/role'
require_relative 'api/namespace/saved_object'
require_relative 'api/namespace/space'
require_relative 'api/namespace/dashboard'

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
                Kibana::API::Dashboard
    end

  end
end