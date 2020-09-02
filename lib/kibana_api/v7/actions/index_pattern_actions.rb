module KibanaAPI
  module V7
    module Actions
      module IndexPatternActions

        # Retrieves a Kibana index pattern
        # @param id [String] Index pattern id 
        # @return [Object] Parsed response
        def get_index_pattern(id)
          get_saved_object_by_id("index-pattern", id)
        end

        # Verify that an index pattern exists
        # @param id [String] Index pattern id 
        # @return [Boolean] 
        def index_pattern_exists?(id)
          saved_object_exists?("index-pattern", id)
        end

        # Creates a Kibana index pattern
        # @param params [Object] Index pattern params
        # @param id [String] Index pattern id 
        # @param space_id [String] Index pattern space
        # @return [Object] Parsed response
        def create_index_pattern(params, id = "", space_id = "")
          create_saved_object(params, "index-pattern", id, space_id)
        end

        # Updates a Kibana index pattern
        # @param params [Object] Index pattern params
        # @param id [String] Index pattern id 
        # @param space_id [String] Index pattern space
        # @return [Object] Parsed response
        def update_index_pattern(params, id, space_id = "")
          update_saved_object(params, "index-pattern", id, space_id)
        end

      end
    end
  end
end