module Kibana
  module API
    module Actions
      module Space
        
        # Creates a Kibana space 
        # @param params [Object] Space params
        # @return [Object] Parsed response
        def create_space(params)
          request(
            http_method: :post,
            endpoint: "api/spaces/space",
            params: params.to_json
          )
        end

        # Creates multiple Kibana spaces
        # @param params [Array] Array of space params
        # @return [Object] Parsed response
        def create_spaces(params)
          params.each { |params| create_space(options) }
        end
      end
    end
  end
end