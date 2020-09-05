module Kibana
  module API
    class UserClient < Client

      def features
        request(
          http_method: :get,
          endpoint: "api/features"
        )
      end 
      
    end
  end
end