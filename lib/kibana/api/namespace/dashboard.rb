module Kibana
  module API

    module Dashboard
      # Proxy method for {DashboardClient}, available in the receiving object
      def dashboard
        # Thread.current['dashboard_client'] ||= DashboardClient.new(self)
        @dashboard = DashboardClient.new(self)
      end
    end

    class DashboardClient < BaseClient

      include Kibana::API::Spaceable

      # Imports a kibana dashboard
      # @param body [Object] The payload to be imported
      # @param params [Object] query params
      # @return [Object] Parsed response
      def import(body:, params: {}, **args)
        params = symbolize_keys(params).slice(:force, :exclude)
        body = symbolize_keys(body).slice(:objects)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/kibana/dashboards/import",
          params: params,
          body: body
        ))
      end

      # Exports a Kibana dashboard
      # @param params [Object] query params
      # @return [Object] Parsed response
      def export(params:, **args)
        params = symbolize_keys(params).slice(:dashboard)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/kibana/dashboards/export",
          params: params
        ))
      end
    end

  end
end