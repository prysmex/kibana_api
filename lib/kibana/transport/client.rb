module Kibana
  module Transport
    class Client
  
      include HttpStatusCodes
      include ApiExceptions
  
      attr_reader :api_host, :api_key
  
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end
  
      # Simple wrapper to execute the http method on the connection object
      # use block to customize the connection object
      def request(http_method:, endpoint:, params: {}, body: {}, raw_body: nil, raw: false, &block)

        body = raw_body ? body : body.to_json

        response = connection.public_send(http_method, endpoint) do |conn|
          conn.params = conn.params.merge(params)
          conn.body = body
          conn.headers = conn.headers.merge({'Content-Type' => 'application/json;charset=UTF-8'}) unless raw
          yield conn if block_given?
        end

        unless response_successful?(response)
          raise error_class(response), "Code: #{response.status}, response: #{response.body}"
        end

        if raw
          response
        else
          Oj.load(response.body)
        end
      end
  
      private
  
      # Faraday connection object with default configurations
      # this can be configured in a per-request basis by yielding
      # the connection object on the request or raw_request methods
      # TODO myabe implement this? https://lostisland.github.io/faraday/middleware/multipart
      def connection
        @connection ||= Faraday.new(@api_host, {request: { params_encoder: Faraday::FlatParamsEncoder }}) do |c|
          c.request :multipart
          c.request :url_encoded
          c.adapter Faraday.default_adapter
          # Default Kibana API Headers
          c.headers['kbn-xsrf'] = 'true'
          c.headers['Authorization'] = "ApiKey #{@api_key}"
          # c.headers['Content-Type'] = 'application/json;charset=UTF-8'
        end
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
        [
          HTTP_NO_CONTENT, HTTP_OK_CODE
        ].include?(response.status)
      end
      
    end
  end
end