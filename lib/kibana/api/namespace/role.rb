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
    #   "transient_metadata": {
    #     "enabled": true
    #   },
    #   "elasticsearch": {
    #     "cluster": [],
    #     "indices": [],
    #     "run_as": []
    #   },
    #   "kibana": [
    #     {
    #       "base": [],
    #       "feature": {
    #         "discover_v2": ["minimal_read", "url_create", "store_search_session", "generate_report"],
    #         "dashboard_v2": [ "minimal_read", "url_create", "store_search_session", "generate_report", "download_csv_report" ],
    #         "maps_v2": [ "read" ],
    #         "ml": [ "read" ],
    #         "graph": [ "read" ],
    #         "visualize_v2": [ "minimal_read", "url_create", "generate_report" ],
    #         "searchSynonyms": [ "all" ],
    #         "enterpriseSearch": [ "all" ],
    #         "searchPlayground": [ "all" ],
    #         "searchInferenceEndpoints": [ "all" ],
    #         "enterpriseSearchApplications": [ "all" ],
    #         "enterpriseSearchAnalytics": [ "all" ],
    #         "logs": [ "read" ],
    #         "infrastructure": [ "read" ],
    #         "apm": [ "minimal_read", "settings_save" ],
    #         "inventory": [ "read" ],
    #         "uptime": [ "minimal_read", "elastic_managed_locations_enabled", "can_manage_private_locations" ],
    #         "observabilityCasesV3": [ "minimal_read", "cases_delete", "cases_settings", "create_comment", "case_reopen", "cases_assign" ],
    #         "slo": [ "read" ],
    #         "fleet": [ "read" ],
    #         "stackAlerts": [ "read" ],
    #         "maintenanceWindow": [ "read" ],
    #         "rulesSettings": [ "minimal_read", "readFlappingSettings" ],
    #         "entityManager": [ "read" ],
    #         "aiAssistantManagementSelection": [ "read" ],
    #         "generalCasesV3": [ "minimal_read", "cases_delete", "cases_settings", "create_comment", "case_reopen", "cases_assign" ],
    #         "actions": [ "minimal_read", "endpoint_security_execute" ],
    #         "osquery": [ "minimal_read", "live_queries_read", "run_saved_queries", "saved_queries_read", "packs_read" ],
    #         "savedObjectsTagging": [ "read" ],
    #         "savedQueryManagement": [ "read" ],
    #         "savedObjectsManagement": [ "read" ],
    #         "filesSharedImage": [ "read" ],
    #         "filesManagement": [ "read" ],
    #         "indexPatterns": [ "read" ],
    #         "advancedSettings": [ "read" ],
    #         "dev_tools": [ "read" ],
    #         "securitySolutionSiemMigrations": [ "all" ],
    #         "securitySolutionAttackDiscovery": [ "all" ],
    #         "securitySolutionAssistant": [ "minimal_all", "update_anonymization", "manage_global_knowledge_base" ],
    #         "securitySolutionNotes": [ "read" ],
    #         "securitySolutionTimeline": [ "read" ],
    #         "securitySolutionCasesV3": [ "minimal_read", "cases_delete", "cases_settings", "create_comment", "case_reopen", "cases_assign" ],
    #         "siemV2": [
    #           "minimal_read",
    #           "endpoint_list_read",
    #           "workflow_insights_read",
    #           "trusted_applications_read",
    #           "host_isolation_exceptions_read",
    #           "blocklist_read",
    #           "event_filters_read",
    #           "policy_management_read",
    #           "actions_log_management_read",
    #           "host_isolation_all",
    #           "process_operations_all",
    #           "file_operations_all",
    #           "execute_operations_all",
    #           "scan_operations_all"
    #         ],
    #         "observabilityAIAssistant": [ "all" ],
    #         "dataQuality": [ "all" ],
    #         "guidedOnboardingFeature": [ "all" ],
    #         "canvas": [ "minimal_read", "generate_report" ],
    #         "fleetv2": [ "minimal_read", "agents_read", "agent_policies_read", "settings_read" ]
    #       },
    #       "spaces": [ "*" ]
    #     }
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