module Kibana
  module API
    module Actions
      module SavedObject

        # Retrieves a single Kibana saved object 
        # @param type [String] Type of the saved object
        # @param id [String] Id of the saved object
        # @return [Object] Parsed response
        def get_saved_object_by_id(type, id)
          request(
            http_method: :get,
            endpoint: "api/saved_objects/#{type}/#{id}"
          )
        end

        # Verify that a saved object exists
        # @param id [String] Saved object id 
        # @return [Boolean] 
        def saved_object_exists?(type, id)
          begin
            get_saved_object_by_id(type, id).present?
          rescue ApiExceptions::NotFoundError
            false
          end
        end

        # Creates a Kibana saved object 
        # @param params [Object] Saved object params
        # @param type [String] Saved object type
        # @param id [String] Saved object id 
        # @param space_id [String] Saved object space
        # @return [Object] Parsed response
        def create_saved_object(params, type, id = "", space_id = "")
          endpoint = if space_id.present?
            "s/#{space_id}/api/saved_objects/#{type}/#{id}"
          else
            "api/saved_objects/#{type}/#{id}"
          end

          request(
            http_method: :post,
            endpoint: endpoint,
            params: params.to_json
          )
        end

        # Updates a Kibana saved object 
        # @param params [Object] Saved object params
        # @param type [String] Saved object type
        # @param id [String] Saved object id 
        # @param space_id [String] Saved object space
        # @return [Object] Parsed response
        def update_saved_object(params, type, id, space_id = "")
          endpoint = if space_id.present?
            "s/#{space_id}/api/saved_objects/#{type}/#{id}"
          else
            "api/saved_objects/#{type}/#{id}"
          end

          request(
            http_method: :put,
            endpoint: endpoint,
            params: params.to_json
          )
        end
      end
    end
  end
end