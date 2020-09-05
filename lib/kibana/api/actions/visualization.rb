module Kibana
  module API
    module Actions
      module Visualization

        # Retrieves a Kibana visualization
        # @param id [String] Visualization id 
        # @return [Object] Parsed response
        def get_visualization(id)
          get_saved_object_by_id("visualization", id)
        end

        # Verify that a visualization exists
        # @param id [String] Visualization id 
        # @return [Boolean] 
        def visualization_exists?(id)
          saved_object_exists?("visualization", id)
        end

        # Creates a Kibana visualization
        # @param params [Object] Visualization params
        # @param id [String] Visualization id 
        # @param space_id [String] Visualization space
        # @return [Object] Parsed response
        def create_visualization(params, id = "", space_id = "")
          create_saved_object(params, "visualization", id, space_id)
        end

        # Updates a Kibana visualization
        # @param params [Object] Visualization params
        # @param id [String] Visualization id 
        # @param space_id [String] Visualization space
        # @return [Object] Parsed response
        def update_visualization(params, id, space_id = "")
          update_saved_object(params, "visualization", id, space_id)
        end

      end
    end
  end
end