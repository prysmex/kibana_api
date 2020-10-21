module Kibana
  module API
    class SpaceClient < Client
      
      # Creates a Kibana space
      # @param body [Object] Space body
      # @return [Object] Parsed response
      def create(body)
        request(
          http_method: :post,
          endpoint: "api/spaces/space",
          body: validate_body(body)
        )
      end

      # Updates a Kibana space 
      # @param id [String] Space id
      # @param body [Object] Space body
      # @return [Object] Parsed response
      def update(id, body)
        request(
          http_method: :put,
          endpoint: "api/spaces/space/#{id}",
          body: validate_body(body)
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

      # TODO Copy saved objects to space
      # TODO Resolve copy to space conflicts

      private

      #req: id(str), name(str), 
      #optional: description(str), disabledFeatures(array, str), initials(str), color(str), imageUrl(str)
      def validate_body(body)
        #required
        raise ArgumentError, "Required argument 'id' missing" unless body[:id]
        raise ArgumentError, "Required argument 'name' missing" unless body[:name]

        #data type
        raise ArgumentError, "'id' must be a string" unless body[:id].is_a?(String)
        raise ArgumentError, "'name' must be a string" unless body[:name].is_a?(String)
        raise ArgumentError, "'description' must be a string" if body[:description] && !body[:description].is_a?(String)
        if body[:disabledFeatures]
          raise ArgumentError, "'disabledFeatures' must be an array" if !body[:disabledFeatures].is_a?(Array)
          body[:disabledFeatures].each do |f|
            unless f.is_a?(String)
              raise ArgumentError, "'disabledFeatures' must be an array of strings"
            end
          end
        end
        raise ArgumentError, "'initials' must be a string" if body[:initials] && !body[:initials].is_a?(String)
        raise ArgumentError, "'color' must be a string" if body[:color] && !body[:color].is_a?(String)
        raise ArgumentError, "'imageUrl' must be a string" if body[:imageUrl] && !body[:imageUrl].is_a?(String)
        body.slice(:id, :name, :description, :disabledFeatures, :initials, :color, :imageUrl)
      end
      
    end
  end
end