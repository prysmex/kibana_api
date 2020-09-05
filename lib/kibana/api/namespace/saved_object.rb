module Kibana
  module API
    class SavedObjectClient < Client

      attr_reader :type

      # Retrieves a single Kibana saved object 
      # @param id [String] Id of the saved object
      # @param type [String] Type of the saved object
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def get_by_id(id, type, space_id = "")
        request(
          http_method: :get,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}"
        )
      end

      # Retrieves multiple Kibana saved object 
      # @param params [Object] Saved object body
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def bulk_get(params, space_id = "")
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_bulk_get",
          params: params.to_json
        )
      end

      # Retrieves multiple paginated Kibana saved objects
      # @param params [Object] Saved object body
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def find(params, space_id = "")
        request(
          http_method: :get,
          endpoint: "#{build_endpoint_with_space(space_id)}/_find",
          params: params.to_json
        )
      end

      # Verify that a saved object exists
      # @param type [String] Type of the saved object
      # @param id [String] Saved object id 
      # @param space_id [String] Saved object space
      # @return [Boolean] 
      def exists?(id, type, space_id = "")
        begin
          get_by_id(id, type, space_id).present?
        rescue ApiExceptions::NotFoundError
          false
        end
      end

      # Creates a Kibana saved object 
      # @param params [Object] Saved object body
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param space_id [String] Saved object space
      # @param options [String] Saved object options
      # @return [Object] Parsed response
      def create(params, type, id = "", space_id = "", options = {})
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}",
          params: params.to_json
        )
      end

      # Creates multiple Kibana saved object 
      # @param params [Object] Saved object body
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def bulk_create(params, space_id = "", options = {})
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_bulk_create",
          params: params.to_json
        )
      end

      # Updates a Kibana saved object 
      # @param params [Object] Saved object body
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param space_id [String] Saved object space
      # @param options [String] Saved object options
      # @return [Object] Parsed response
      def update(params, type, id, space_id = "", options = {})
        request(
          http_method: :put,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}",
          params: params.to_json
        )
      end

      # Deletes a Kibana saved object 
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def delete(id, type, space_id = "")
        request(
          http_method: :delete,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}"
        )
      end

      # Imports Kibana saved object 
      # @param params [Object] Saved object body
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def import(params, space_id = "")
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_import",
          params: params.to_json
        )
      end

      # Exports Kibana saved object 
      # @param params [Object] Saved object body
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def export(params, space_id = "", options = {})
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_export",
          params: params.to_json
        )
      end

      # Resolve import errors from Kibana saved object 
      # @param params [Object] Saved object body
      # @param space_id [String] Saved object space
      # @return [Object] Parsed response
      def resolve_import_errors(params, space_id = "", options = {})
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_resolve_import_errors",
          params: params.to_json
        )
      end

      private

      def build_endpoint_with_space(space_id)
        if space_id.present?
          "s/#{space_id}/api/saved_objects"
        else
          "api/saved_objects"
        end
      end

    end
  end
end