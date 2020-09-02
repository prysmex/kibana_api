module KibanaAPI
  module V7
    module Actions
      module UserActions
        def user_features
          request(
            http_method: :get,
            endpoint: "api/features"
          )
        end
      end
    end
  end
end
