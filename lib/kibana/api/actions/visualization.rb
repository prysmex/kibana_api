module Kibana
  module API
    module Actions
      module Visualization

        # Retrieves a single Kibana visualization 
        # @option type [String] Type of the visualization
        # @option id [String] Id of the visualization
        # @option space_id [String] Visualization space
        # @return [Object] Parsed response
        def get_visualization(options)
          get_saved_object_by_id(options.merge({type: "index-pattern"}))
        end

        # Verify that a visualization exists
        # @option type [String] Type of the visualization
        # @option id [String] Visualization id 
        # @option space_id [String] Visualization space
        # @return [Boolean] 
        def visualization_exists?(options)
          saved_object_exists?(options.merge({type: "index-pattern"}))
        end

        # Creates a Kibana visualization 
        # @option body [Object] Visualization body
        # @option type [String] Visualization type
        # @option id [String] Visualization id 
        # @option space_id [String] Visualization space
        # @return [Object] Parsed response
        def create_visualization(options)
          create_saved_object(options.merge({type: "index-pattern"}))
        end

        # Updates a Kibana visualization 
        # @option body [Object] Visualization body
        # @option type [String] Visualization type
        # @option id [String] Visualization id 
        # @option space_id [String] Visualization space
        # @return [Object] Parsed response
        def update_visualization(options)
          update_saved_object(options.merge({type: "index-pattern"}))
        end

        # Deletes a Kibana visualization 
        # @option type [String] Visualization type
        # @option id [String] Visualization id 
        # @option space_id [String] Visualization space
        # @return [Object] Parsed response
        def delete_visualization(options)
          delete_saved_object(options.merge({type: "index-pattern"}))
        end

      end
    end
  end
end