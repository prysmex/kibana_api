#ToDo maybe this should be a module instead of a class?

module Kibana
  module API

    module ClassMethods

      attr_writer :features_client, :role_client, :saved_object_client, :space_client
      def features_client
        @features_client ||= FeatureClient.new
      end

      def role_client
        @role_client ||= RoleClient.new
      end

      def saved_object_client
        @saved_objects_client ||= SavedObjectClient.new
      end

      def space_client
        @space_client ||= SpaceClient.new
      end
    end

    extend ClassMethods

    class Client

      include HttpStatusCodes
      include ApiExceptions

      private

      def client
        Faraday.new(Kibana.configuration.api_host, {request: { params_encoder: Faraday::FlatParamsEncoder }}) do |client|
          client.request :url_encoded
          client.adapter Faraday.default_adapter
          # Default Kibana API Headers
          client.headers['kbn-xsrf'] = "true"
          client.headers['Authorization'] = "ApiKey #{Kibana.configuration.api_key}"
          client.headers['Content-Type'] = "application/json;charset=UTF-8"
        end
      end

      def request(http_method:, endpoint:, params: {}, body: {})
        response = client.public_send(http_method, endpoint) do |req|
          req.params = req.params.merge(params)
          req.body = body.to_json
        end
        parsed_response = Oj.load(response.body)

        return parsed_response if response_successful?(response)

        raise error_class(response), "Code: #{response.status}, response: #{response.body}"
      end

      def error_class(response)
        case response.status
        when HTTP_BAD_REQUEST_CODE
          BadRequestError
        when HTTP_UNAUTHORIZED_CODE
          UnauthorizedError
        when HTTP_FORBIDDEN_CODE
          ForbiddenError
        when HTTP_NOT_FOUND_CODE
          NotFoundError
        when HTTP_UNPROCESSABLE_ENTITY_CODE
          UnprocessableEntityError
        else
          ApiError
        end
      end
      
      def response_successful?(response)
        response.status == HTTP_OK_CODE
      end
      
    end
  end
end