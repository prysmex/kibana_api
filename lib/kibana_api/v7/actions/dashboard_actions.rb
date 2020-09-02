module KibanaAPI
  module V7
    module Actions
      module DashboardActions

        # Retrieves a Kibana dashboard
        # @param id [String] Dashboard id 
        # @return [Object] Parsed response
        def get_dashboard(id)
          get_saved_object_by_id("index-pattern", id)
        end

        # Verify that a dashboard exists
        # @param id [String] Dashboard id 
        # @return [Boolean] 
        def dashboard_exists?(id)
          saved_object_exists?("dashboard", id)
        end

        # Creates a Kibana dashboard
        # @param params [Object] Dashboard params
        # @param id [String] Dashboard id 
        # @param space_id [String] Dashboard space
        # @return [Object] Parsed response
        def create_dashboard(params, id = "", space_id = "")
          create_saved_object(params, "dashboard", id, space_id)
        end

        # Updates a Kibana dashboard
        # @param params [Object] Dashboard params
        # @param id [String] Dashboard id 
        # @param space_id [String] Dashboard space
        # @return [Object] Parsed response
        def update_dashboard(params, id, space_id = "")
          update_saved_object(params, "dashboard", id, space_id)
        end

      end
    end
  end
end