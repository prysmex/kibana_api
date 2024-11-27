# frozen_string_literal: true

module Kibana
  module API

    module Role
      # Proxy method for {RoleClient}, available in the receiving object
      def role
        # Thread.current['role_client'] ||= RoleClient.new(self)
        @role = RoleClient.new(self)
      end
    end

    #  sample as of 8.7.0
    #
    # {
    #   "name": "test",
    #   "metadata": {},
    #   "transient_metadata": { "enabled": true },
    #   "elasticsearch": { "cluster": [], "indices": [], "run_as": [] },
    #   "kibana": [
    #     {
    #       "base": [],
    #       "feature": {
    #         "discover": [
    #           "minimal_read",
    #           "url_create",
    #           "store_search_session",
    #           "generate_report"
    #         ],
    #         "dashboard": [
    #           "minimal_read",
    #           "url_create",
    #           "store_search_session",
    #           "generate_report",
    #           "download_csv_report"
    #         ],
    #         "canvas": ["minimal_read", "generate_report"],
    #         "maps": ["read"],
    #         "ml": ["read"],
    #         "graph": ["read"],
    #         "visualize": ["minimal_read", "url_create", "generate_report"],
    #         "logs": ["read"],
    #         "infrastructure": ["read"],
    #         "apm": ["read"],
    #         "uptime": ["read"],
    #         "observabilityCases": ["minimal_read", "cases_delete"],
    #         "securitySolutionCases": ["minimal_read", "cases_delete"],
    #         "siem": ["minimal_read"],
    #         "dev_tools": ["read"],
    #         "advancedSettings": ["read"],
    #         "indexPatterns": ["read"],
    #         "filesManagement": ["read"],
    #         "filesSharedImage": ["read"],
    #         "savedObjectsManagement": ["read"],
    #         "savedObjectsTagging": ["read"],
    #         "osquery": [
    #           "minimal_read",
    #           "live_queries_read",
    #           "run_saved_queries",
    #           "saved_queries_read",
    #           "packs_read"
    #         ],
    #         "actions": ["read"],
    #         "generalCases": ["minimal_read", "cases_delete"],
    #         "rulesSettings": ["minimal_read", "readFlappingSettings"],
    #         "stackAlerts": ["read"],
    #         "fleet": ["read"]
    #       },
    #       "spaces": ["default"]
    #     },
    #     { "base": ["read"], "feature": {}, "spaces": ["default"] },
    #     { "base": ["all"], "feature": {}, "spaces": ["test"] }
    #   ],
    #   "_transform_error": [],
    #   "_unrecognized_applications": []
    # }

    class RoleClient < BaseClient

      # Updates a Kibana role
      #
      # @param id [String] Role id
      # @param body [Object] Role body
      #   @option body [Hash] :metadata
      #   @option body [Hash] :elasticsearch
      #   @option body [Array] :kibana
      # @return [NilClass]
      def put(id:, body:, **args)
        body = symbolize_keys(body).slice(:metadata, :elasticsearch, :kibana)

        request(
          **args,
          http_method: :put,
          endpoint: "api/security/role/#{id}",
          body:
        )
      end

      # Gets a Kibana role
      #
      # @param id [String] Role id
      # @return [Hash]
      def get_by_id(id:, **args)
        request(
          **args,
          http_method: :get,
          endpoint: "api/security/role/#{id}"
        )
      end

      # Gets all Kibana roles
      #
      # @return [Array]
      def get_all(**args)
        request(
          **args,
          http_method: :get,
          endpoint: 'api/security/role'
        )
      end

      # Deletes a Kibana role
      #
      # @param id [String] Role id
      # @return [NilClass]
      def delete(id:, **args)
        request(
          **args,
          http_method: :delete,
          endpoint: "api/security/role/#{id}"
        )
      end

    end

  end
end