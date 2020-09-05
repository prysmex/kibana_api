module Kibana
  module API
    module Actions
      module IndexPattern

        # Retrieves a single Kibana index pattern 
        # @option type [String] Type of the index pattern
        # @option id [String] Id of the index pattern
        # @option space_id [String] Index pattern space
        # @return [Object] Parsed response
        def get_index_pattern(options)
          get_saved_object_by_id(options.merge({type: "index-pattern"}))
        end

        # Verify that a index pattern exists
        # @option type [String] Type of the index pattern
        # @option id [String] Index pattern id 
        # @option space_id [String] Index pattern space
        # @return [Boolean] 
        def index_pattern_exists?(options)
          saved_object_exists?(options.merge({type: "index-pattern"}))
        end

        # Creates a Kibana index pattern 
        # @option body [Object] Index pattern body
        # @option type [String] Index pattern type
        # @option id [String] Index pattern id 
        # @option space_id [String] Index pattern space
        # @return [Object] Parsed response
        def create_index_pattern(options)
          create_saved_object(options.merge({type: "index-pattern"}))
        end

        # Updates a Kibana index pattern 
        # @option body [Object] Index pattern body
        # @option type [String] Index pattern type
        # @option id [String] Index pattern id 
        # @option space_id [String] Index pattern space
        # @return [Object] Parsed response
        def update_index_pattern(options)
          update_saved_object(options.merge({type: "index-pattern"}))
        end

        # Deletes a Kibana index pattern 
        # @option type [String] Index pattern type
        # @option id [String] Index pattern id 
        # @option space_id [String] Index pattern space
        # @return [Object] Parsed response
        def delete_index_pattern(options)
          delete_saved_object(options.merge({type: "index-pattern"}))
        end

      end
    end
  end
end