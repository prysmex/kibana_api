module Kibana
  module API
    class SpaceClient < Client
      
      # Creates a Kibana space
      # @param params [Object] Space body
      # @return [Object] Parsed response
      def create(params)
        request(
          http_method: :post,
          endpoint: "api/spaces/space/",
          params: params.to_json
        )
      end

      # Updates a Kibana space 
      # @param id [String] Space id
      # @param params [Object] Space body
      # @return [Object] Parsed response
      def update(id, params)
        request(
          http_method: :put,
          endpoint: "api/spaces/space/#{id}",
          params: params.to_json
        )
      end

      # Gets a Kibana space 
      # @param id [String] Space id
      # @return [Object] Parsed response
      def get_by_id(id)
        request(
          http_method: :get,
          endpoint: "api/spaces/space/#{id}"
        )
      end

      # Gets all Kibana spaces
      # @return [Object] Parsed response
      def get_all
        request(
          http_method: :get,
          endpoint: "api/spaces/space/"
        )
      end

      # Deletes a Kibana space 
      # @param id [String] Space id
      # @return [Object] Parsed response
      def delete(id)
        request(
          http_method: :delete,
          endpoint: "api/spaces/space/#{params[:id]}"
        )
      end

      # TODO Copy saved objects to space
      # TODO Resolve copy to space conflicts
      
    end
  end
end