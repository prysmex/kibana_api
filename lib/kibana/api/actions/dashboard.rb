module Kibana
  module API
    module Actions
      module Dashboard

        # Retrieves a single Kibana dashboard 
        # @option type [String] Type of the dashboard
        # @option id [String] Id of the dashboard
        # @option space_id [String] Dashboard space
        # @return [Object] Parsed response
        def get_index_pattern(options)
          get_saved_object_by_id(options.merge({type: "index-pattern"}))
        end

        # Verify that a dashboard exists
        # @option type [String] Type of the dashboard
        # @option id [String] Dashboard id 
        # @option space_id [String] Dashboard space
        # @return [Boolean] 
        def index_pattern_exists?(options)
          saved_object_exists?(options.merge({type: "index-pattern"}))
        end

        # Creates a Kibana dashboard 
        # @option body [Object] Dashboard body
        # @option type [String] Dashboard type
        # @option id [String] Dashboard id 
        # @option space_id [String] Dashboard space
        # @return [Object] Parsed response
        def create_index_pattern(options)
          create_saved_object(options.merge({type: "index-pattern"}))
        end

        # Updates a Kibana dashboard 
        # @option body [Object] Dashboard body
        # @option type [String] Dashboard type
        # @option id [String] Dashboard id 
        # @option space_id [String] Dashboard space
        # @return [Object] Parsed response
        def update_index_pattern(options)
          update_saved_object(options.merge({type: "index-pattern"}))
        end

        # Deletes a Kibana dashboard 
        # @option type [String] Dashboard type
        # @option id [String] Dashboard id 
        # @option space_id [String] Dashboard space
        # @return [Object] Parsed response
        def delete_index_pattern(options)
          delete_saved_object(options.merge({type: "index-pattern"}))
        end

      end
    end
  end
end