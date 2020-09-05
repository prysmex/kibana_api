module Kibana
  module API
    class User < Client

      def features
        request(
          http_method: :get,
          endpoint: "api/features"
        )
      end 
      
    end
  end
end