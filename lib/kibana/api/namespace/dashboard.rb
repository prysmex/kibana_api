module Kibana
  module API

    # @note Deprecated in 7.15.0
    # These experimental APIs have been deprecated in favor of Import objects and Export objects.

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
      #
      # @param body [Hash] The payload to be imported
      # @param params [Hash] query params
      #   @option params [Boolean] :force, optional
      #   @option params [Array] :exclude, optional
      # @return [Array]
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
      #
      # @param params [Hash] query params
      #   @option params [String,Array] :dashboard, optional
      # @return [Array]
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