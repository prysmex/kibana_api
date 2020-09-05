module Kibana
  module API
    class RoleClient < Client
      
      # Updates a Kibana role 
      # @param id [String] Role id
      # @param params [Object] Role body
      # @return [Object] Parsed response
      def create(id, params)
        update(id, params)
      end

      # Updates a Kibana role 
      # @param id [String] Role id
      # @param params [Object] Role body
      # @return [Object] Parsed response
      def update(id, params)
        request(
          http_method: :put,
          endpoint: "/api/security/role/#{id}",
          params: params.to_json
        )
      end

      # Gets a Kibana role 
      # @param id [String] Role id
      # @return [Object] Parsed response
      def get_by_id(id)
        request(
          http_method: :get,
          endpoint: "/api/security/role/#{id}"
        )
      end

      # Gets all Kibana roles
      # @return [Object] Parsed response
      def get_all
        request(
          http_method: :get,
          endpoint: "/api/security/role/"
        )
      end

      # Deletes a Kibana role 
      # @param id [String] Role id
      # @return [Object] Parsed response
      def delete(id)
        request(
          http_method: :delete,
          endpoint: "/api/security/role/#{id}"
        )
      end
      
    end
  end
end