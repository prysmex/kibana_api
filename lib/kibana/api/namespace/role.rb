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
        body = symbolize_keys(body)
        request(
          http_method: :put,
          endpoint: "api/security/role/#{id}",
          body: filter_keys(body)
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

      def filter_keys(body)
        body.transform_keys{|k| k.to_sym}.slice(
          :metadata, :elasticsearch, :kibana
        )
      end
      
    end
  end
end