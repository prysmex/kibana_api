module Kibana
  module API
    module Actions
      module User
        def features
          request(
            http_method: :get,
            endpoint: "api/features"
          )
        end
      end
    end
  end
end
