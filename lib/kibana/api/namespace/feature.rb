module Kibana
  module API
    class FeatureClient < Client

      def features
        request(
          http_method: :get,
          endpoint: "api/features"
        )
      end 
      
    end
  end
end