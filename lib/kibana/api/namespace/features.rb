module Kibana
  module API

    module Features
      # Proxy method for {FeaturesClient}, available in the receiving object
      def features
        @features ||= FeaturesClient.new(self)
      end
    end

    class FeaturesClient < BaseClient
      def features
        request(
          http_method: :get,
          endpoint: "api/features"
        )
      end 
    end

  end
end