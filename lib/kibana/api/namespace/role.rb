module Kibana
  module API

    module Role
      # Proxy method for {RoleClient}, available in the receiving object
      def role
        @role ||= RoleClient.new(self)
      end
    end

    class RoleClient < BaseClient
        
      # Updates a Kibana role 
      # @param id [String] Role id
      # @param body [Object] Role body
      # @return [Object] Parsed response
      def create(**args)
        update(**args)
      end

      # Updates a Kibana role 
      # @param id [String] Role id
      # @param body [Object] Role body
      # @return [Object] Parsed response
      def update(id:, body:, **args)
        body = symbolize_keys(body).slice(:metadata, :elasticsearch, :kibana)

        request(**args.merge(
          http_method: :put,
          endpoint: "api/security/role/#{id}",
          body: body
        ))
      end

      # Gets a Kibana role 
      # @param id [String] Role id
      # @return [Object] Parsed response
      def get(id:, **args)
        request(**args.merge(
          http_method: :get,
          endpoint: "api/security/role/#{id}"
        ))
      end

      # Gets all Kibana roles
      # @return [Object] Parsed response
      def get_all(**args)
        request(**args.merge(
          http_method: :get,
          endpoint: "api/security/role"
        ))
      end

      # Deletes a Kibana role 
      # @param id [String] Role id
      # @return [Object] Parsed response
      def delete(id:, **args)
        request(**args.merge(
          http_method: :delete,
          endpoint: "api/security/role/#{id}"
        ))
      end

    end

  end
end