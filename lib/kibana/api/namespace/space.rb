module Kibana
  module API
    class SpaceClient < Client

      FEATURES = [
        :advancedSettings, :indexPatterns, :savedObjectsManagement, :ingestManager,
        :monitoring, :siem, :uptime, :apm, :logs, :infrastructure, :ml, :enterpriseSearch,
        :discover, :visualize, :dashboard, :canvas, :maps, :dev_tools, :graph
      ].freeze

      # BODY_TEMPLATE = {
        # id: nil,
        # name: nil,
        # description: nil,
        # initials: nil, # two letters
        # color: nil,
        # disabledFeatures: []
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
          endpoint: "api/spaces/space",
          body: body
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
          body: body
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
          endpoint: "api/spaces/space"
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
      # @param id [String] Saved object id 
      # @return [Boolean] 
      def exists?(id)
        begin
          get_by_id(id).present?
        rescue ApiExceptions::NotFoundError
          false
        end
      end

      # TODO Copy saved objects to space
      # TODO Resolve copy to space conflicts

      private

      def validate_required(body)
        raise ArgumentError, "Required argument 'id' missing" unless body[:id]
        raise ArgumentError, "Required argument 'name' missing" unless body[:name]
        validate_datatypes(body)
      end

      def validate_datatypes(body)
        raise ArgumentError, "'id' must be a string or a hash" if body[:id] && ![String, Hash].include?(body[:id].class)
        raise ArgumentError, "'name' must be a string" if body[:name] && !body[:name].is_a?(String)
        raise ArgumentError, "'description' must be a string" if body[:description] && !body[:description].is_a?(String)
        if body[:disabledFeatures]
          raise ArgumentError, "'disabledFeatures' must be an array" if !body[:disabledFeatures].is_a?(Array)
          body[:disabledFeatures].each do |f|
            if !FEATURES.include?(f.to_sym)
              raise ArgumentError, "'#{f}' is not a valid feature"
            end
          end
        end
        raise ArgumentError, "'initials' must be a string" if body[:initials] && !body[:initials].is_a?(String)
        raise ArgumentError, "'color' must be a string" if body[:color] && !body[:color].is_a?(String)
        raise ArgumentError, "'imageUrl' must be a string" if body[:imageUrl] && !body[:imageUrl].is_a?(String)
      end

      def symbolize_and_filter(body)
        body.transform_keys{|k| k.to_sym}.slice(
          :id, :name, :description, :disabledFeatures, :initials, :color, :imageUrl
        )
      end
      
    end
  end
end