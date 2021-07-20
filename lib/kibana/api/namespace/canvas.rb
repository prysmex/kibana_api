module Kibana
  module API

    module Canvas
      # Proxy method for {CanvasClient}, available in the receiving object
      def canvas
        @canvas = CanvasClient.new(self)
      end
    end

    class CanvasClient < BaseClient

      include Kibana::API::Spaceable

      # Retrieves multiple paginated Kibana canvas
      # @param params [Object] query params (:per_page)
      # @return [Object] Parsed response
      def find(params:, **args)
        params = symbolize_keys(params).slice(:per_page)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}canvas/workpad/find",
          params: params
        ))
      end
    end

  end
end
