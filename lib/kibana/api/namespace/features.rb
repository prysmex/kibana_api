# frozen_string_literal: true

module Kibana
  module API

    module Features
      # Proxy method for {FeaturesClient}, available in the receiving object
      def features
        # Thread.current['features_client'] ||= FeaturesClient.new(self)
        @features = FeaturesClient.new(self)
      end
    end

    class FeaturesClient < BaseClient

      # Returns the Kibana features
      #
      # @return [Array]
      def features(**args)
        request(
          **args,
          http_method: :get,
          endpoint: 'api/features'
        )
      end
    end

  end
end