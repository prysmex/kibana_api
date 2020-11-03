module Kibana
  module API

    module Dashboard
      # Proxy method for {DashboardClient}, available in the receiving object
      def dashboard
        @dashboard ||= DashboardClient.new(self)
      end
    end

    class DashboardClient < BaseClient

      include Kibana::API::Spaceable

      # Updates a Kibana role 
      # @param id [String] Role id
      # @param body [Object] Role body
      # @return [Object] Parsed response
      def import(id, body)
        body = symbolize_keys(body).slice(:attributes, :references)
        options = symbolize_keys(options).slice()

        request(
          http_method: :put,
          endpoint: "#{current_space_api_namespace}/kibana/dashboards/import",
          params: options,
          body: body
        )
      end

      # Exports a Kibana dashboard
      # @param options [Object] query params
      # @return [Object] Parsed response
      def export(options = {})
        options = symbolize_keys(options).slice(:dashboard)

        request(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/kibana/dashboards/export",
          params: options
        )
      end
    end

  end
end