module Kibana
  module API
    class RoleClient < Client
      
      # Updates a Kibana role 
      # @param id [String] Role id
      # @param body [Object] Role body
      # @return [Object] Parsed response
      def create(id, body)
        update(id, body)
      end

      # Updates a Kibana role 
      # @param id [String] Role id
      # @param body [Object] Role body
      # @return [Object] Parsed response
      def update(id, body)
        request(
          http_method: :put,
          endpoint: "api/security/role/#{id}",
          body: validate_body(body)
        )
      end

      # Gets a Kibana role 
      # @param id [String] Role id
      # @return [Object] Parsed response
      def get_by_id(id)
        request(
          http_method: :get,
          endpoint: "api/security/role/#{id}"
        )
      end

      # Gets all Kibana roles
      # @return [Object] Parsed response
      def get_all
        request(
          http_method: :get,
          endpoint: "api/security/role"
        )
      end

      # Deletes a Kibana role 
      # @param id [String] Role id
      # @return [Object] Parsed response
      def delete(id)
        request(
          http_method: :delete,
          endpoint: "api/security/role/#{id}"
        )
      end

      private

      #req:
      #optional: metadata(obj), elasticsearch(obj), kibana(array => obj)
      def validate_body(body)
        body.slice(:metadata, :elasticsearch, :kibana)
      end
      
    end
  end
end