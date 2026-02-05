# frozen_string_literal: true

module Kibana
  module API

    module Space
      # Proxy method for {SpaceClient}, available in the receiving object
      def space
        # Thread.current['space_client'] ||= SpaceClient.new(self)
        @space = SpaceClient.new(self)
      end
    end

    class SpaceClient < BaseClient

      FEATURES = %i[
        actions advancedSettings agentBuilder aiAssistantManagementSelection apm canvas cloudConnect dashboard_v2 dataQuality
        dev_tools discover_v2 enterpriseSearch enterpriseSearchAnalytics enterpriseSearchApplications filesManagement
        filesSharedImage fleet fleetv2 generalCasesV3 graph indexPatterns infrastructure logs
        maintenanceWindow manageReporting maps_v2 ml monitoring observabilityAIAssistant observabilityCasesV3
        osquery rulesSettings savedObjectsManagement savedObjectsTagging savedQueryManagement searchInferenceEndpoints
        searchPlayground searchQueryRules searchSynonyms securitySolutionAssistant securitySolutionAttackDiscovery
        securitySolutionCasesV3 securitySolutionNotes securitySolutionRulesV1 securitySolutionSiemMigrations securitySolutionTimeline siemV5 slo
        stackAlerts streams uptime visualize_v2 workflowsManagement
      ].freeze

      # BODY_TEMPLATE = {
      #   "id": "marketing",
      #   "name": "Marketing",
      #   "description" : "This is the Marketing Space",
      #   "color": "#aabbcc",
      #   "initials": "MK",
      #   "disabledFeatures": [],
      #   "imageUrl": "",
      #   "solution": "classic"
      # }

      # Creates a Kibana space
      # @param body [Object] Space body
      # @return [Object] Parsed response
      def create(body)
        body = symbolize_and_filter(body)
        validate_required(body)
        validate_datatypes(body)
        request(
          http_method: :post,
          endpoint: 'api/spaces/space',
          body:
        )
      end

      # Updates a Kibana space
      # @param id [String] Space id
      # @param body [Object] Space body
      # @return [Object] Parsed response
      def update(id, body)
        body = symbolize_and_filter(body)
        validate_datatypes(body)
        request(
          http_method: :put,
          endpoint: "api/spaces/space/#{id}",
          body:
        )
      end

      # Gets a Kibana space
      # @param id [String] Space id
      # @return [Object] Parsed response
      def get_by_id(id)
        request(
          http_method: :get,
          endpoint: "api/spaces/space/#{id}"
        )
      end

      # Gets all Kibana spaces
      # @return [Object] Parsed response
      def get_all
        request(
          http_method: :get,
          endpoint: 'api/spaces/space'
        )
      end

      # Deletes a Kibana space
      # @param id [String] Space id
      # @return [Object] Parsed response
      def delete(id)
        request(
          http_method: :delete,
          endpoint: "api/spaces/space/#{id}"
        )
      end

      # Check presence of space
      # @param id [String] Space id
      # @return [Boolean]
      def exists?(id)
        get_by_id(id).present?
      rescue Kibana::Transport::ApiExceptions::NotFoundError
        false
      end

      # TODO: Copy saved objects to space
      # TODO Resolve copy to space conflicts

      # In some cases (like a recently created space) this method
      # might return nil, it returns the 'largest' version of a config
      # object, not necessarily the one for the latest Kibana version
      # @param id [String] Space id
      # @return [Object|nil] latest config saved object or nil
      def get_latest_config(id)
        data = client.saved_object.with_space(id) do |c|
          c.find({params: {type: [:config]}})
        end
        data['saved_objects'].max_by do |object|
          semantic_version_to_f(object['id'])
        end
      end

      # @param source_space [String] id of source space
      # @param to_spaces [String] id of target space
      # @param objects [Array] [{"type":"config","id":"7.9.3"}]
      # @param includeReferences [Boolean]
      # @param overwrite [Boolean]
      # @return [Object] results from every spaces {test_space: {success: true, successCount: 1}}
      def copy_saved_objects_to_spaces(
        source_space:,
        target_spaces:,
        objects:,
        includeReferences: true,
        overwrite: true,
        createNewCopies: false
      )
        request(
          http_method: :post,
          endpoint: "/s/#{source_space}/api/spaces/_copy_saved_objects",
          body: {
            objects:,
            spaces: target_spaces,
            includeReferences:,
            overwrite:,
            createNewCopies:
          }
        )
      end

      private

      def semantic_version_to_f(version)
        version = version.sub(/\A[^\d]/, '') # remove first character if not digit
        version.split('.')
               .map(&:to_i)
               .each_with_index
               .reduce(0) { |sum, arr| sum + (arr[0] / (100.0**arr[1])) }
               .round(4)
      end

      def validate_required(body)
        raise ArgumentError.new("Required argument 'id' missing") unless body[:id]
        raise ArgumentError.new("Required argument 'name' missing") unless body[:name]

        validate_datatypes(body)
      end

      def validate_datatypes(body)
        if body[:id] && ![String, Hash].include?(body[:id].class)
          raise ArgumentError.new("'id' must be a string or a hash")
        end

        raise ArgumentError.new("'name' must be a string") if body[:name] && !body[:name].is_a?(String)

        if body[:description] && !body[:description].is_a?(String)
          raise ArgumentError.new("'description' must be a string")
        end

        if body[:disabledFeatures]
          raise ArgumentError.new("'disabledFeatures' must be an array") unless body[:disabledFeatures].is_a?(Array)

          body[:disabledFeatures].each do |f|
            raise ArgumentError.new("'#{f}' is not a valid feature") unless FEATURES.include?(f.to_sym)
          end
        end
        raise ArgumentError.new("'initials' must be a string") if body[:initials] && !body[:initials].is_a?(String)
        raise ArgumentError.new("'color' must be a string") if body[:color] && !body[:color].is_a?(String)
        raise ArgumentError.new("'imageUrl' must be a string") if body[:imageUrl] && !body[:imageUrl].is_a?(String)
      end

      def symbolize_and_filter(body)
        body.transform_keys(&:to_sym).slice(
          :id, :name, :description, :disabledFeatures, :initials, :color, :imageUrl, :solution
        )
      end

    end

  end
end