module Kibana
  module API
    class SavedObject < Client

      attr_reader :type

      def initialize
        super 
        @type = ""
      end  

      # Retrieves a single Kibana saved object 
      # @option type [String] Type of the saved object
      # @option id [String] Id of the saved object
      # @option space_id [String] Saved object space
      # @return [Object] Parsed response
      def get_by_id(options)
        request(
          http_method: :get,
          endpoint: build_endpoint(:get, options)
        )
      end

      # Verify that a saved object exists
      # @option type [String] Type of the saved object
      # @option id [String] Saved object id 
      # @option space_id [String] Saved object space
      # @return [Boolean] 
      def exists?(options)
        begin
          get_by_id(options).present?
        rescue ApiExceptions::NotFoundError
          false
        end
      end

      # Creates a Kibana saved object 
      # @option body [Object] Saved object body
      # @option type [String] Saved object type
      # @option id [String] Saved object id 
      # @option space_id [String] Saved object space
      # @return [Object] Parsed response
      def create(options)
        request(
          http_method: :post,
          endpoint: build_endpoint(:post, options),
          params: options[:body].to_json
        )
      end

      # Updates a Kibana saved object 
      # @option body [Object] Saved object body
      # @option type [String] Saved object type
      # @option id [String] Saved object id 
      # @option space_id [String] Saved object space
      # @return [Object] Parsed response
      def update(options)
        request(
          http_method: :put,
          endpoint: build_endpoint(:put, options),
          params: options[:body].to_json
        )
      end

      # Deletes a Kibana saved object 
      # @option type [String] Saved object type
      # @option id [String] Saved object id 
      # @option space_id [String] Saved object space
      # @return [Object] Parsed response
      def delete(options)
        request(
          http_method: :delete,
          endpoint: build_endpoint(:delete, options)
        )
      end

      private

      def build_endpoint(method, options = {})
        options = options.merge({type: @type}) if @type.present? 
        validate_options(method, options)
        if options[:space_id].present?
          "s/#{space_id}/api/saved_objects/#{options[:type]}/#{options[:id]}"
        else
          "api/saved_objects/#{options[:type]}/#{options[:id]}"
        end
      end

      def validate_options(method, options)
        raise ArgumentError, "Required argument 'id' missing" if [:get, :put, :delete].include?(method) && options[:id].nil?
        raise ArgumentError, "Required argument 'body' missing" if [:post, :put].include?(method) && options[:body].nil?
        raise ArgumentError, "Required argument 'type' missing" if options[:type].nil?
      end

    end
  end
end