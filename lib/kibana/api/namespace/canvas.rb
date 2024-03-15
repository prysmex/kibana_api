# frozen_string_literal: true

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
      #
      # @param [Hash] params query params
      #   @option params [Integer] :perPage
      #   @option params [NilClass,String] :name
      # @return [Hash]
      def find(params:, **args)
        params = symbolize_keys(params).slice(:perPage, :name)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/canvas/workpad/find",
          params:
        ))
      end
    end

  end
end
