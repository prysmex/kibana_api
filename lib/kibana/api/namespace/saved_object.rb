module Kibana
  module API
    class SavedObjectClient < Client

      TYPES = [
        :config,
        :'index-pattern',
        :visualization,
        :'timelion-sheet',
        :search,
        :dashboard,
        # :url,
        # :query,
        # :map,
        # :'canvas-element',
        # :'canvas-workpad',
        # :'canvas-workpad-template',
        # :lens,
        # :'infrastructure-ui-source',
        # :'metrics-explorer-view',
        # :'inventory-view'
      ].freeze

      # Retrieves a single Kibana saved object 
      # @param id [String] Id of the saved object
      # @param type [String] Type of the saved object
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def get_by_id(type, id, options = {})
        space_id = options.delete(:space_id)
        _validate_type(type)
        request(
          http_method: :get,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}",
          params: options.slice()
        )
      end

      # Retrieves multiple Kibana saved object 
      # @param body [Array] Array of query objects
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def bulk_get(body, options = {})
        space_id = options.delete(:space_id)
        body = body.map do |obj|
          _validate_type(obj[:type])
          obj.slice(:type, :id, :fields)
        end
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_bulk_get",
          body: body,
          params: options.slice()
        )
      end

      # Retrieves multiple paginated Kibana saved objects
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def find(options = {})
        space_id = options.delete(:space_id)
        _validate_type(options[:type]) if options.key?(:type)
        request(
          http_method: :get,
          endpoint: "#{build_endpoint_with_space(space_id)}/_find",
          params: options.slice(:type, :per_page, :page, :search, :default_search_operator, :search_fields, :fields, :sort_field, :has_reference, :filter)
        )
      end

      # Creates a Kibana saved object 
      # @param type [String] Saved object type
      # @param body [Object] Saved object body
      # @param options [Object] space_id, id and query params
      # @return [Object] Parsed response
      def create(type, body, options = {})
        _validate_type(type)
        space_id = options.delete(:space_id)
        id = options.delete(:id)
        endpoint = if id
          "#{build_endpoint_with_space(space_id)}/#{type}/#{id}"
        else
          "#{build_endpoint_with_space(space_id)}/#{type}"
        end
        request(
          http_method: :post,
          endpoint: endpoint,
          params: options.slice(:overwrite),
          body: body.slice(:attributes, :references, :initialNamespaces)
        )
      end

      # Creates multiple Kibana saved object 
      # @param body [Array] Array of saved objects
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def bulk_create(body, options = {})
        space_id = options.delete(:space_id)
        body = body.map do |obj|
          _validate_type(obj[:type])
          obj.slice(:type, :id, :attributes, :references, :initialNamespaces, :version)
        end
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_bulk_create",
          params: options.slice(:overwrite),
          body: body
        )
      end

      # Updates a Kibana saved object 
      # @param body [Object] Saved object body
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def update(body, type, id, options = {})
        space_id = options.delete(:space_id)
        request(
          http_method: :put,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}",
          params: options.slice(),
          body: body.slice(:attributes, :references),
        )
      end

      # Deletes a Kibana saved object 
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def delete(id, type, options = {})
        space_id = options.delete(:space_id)
        request(
          http_method: :delete,
          endpoint: "#{build_endpoint_with_space(space_id)}/#{type}/#{id}",
          params: options.slice(:force)
        )
      end

      # Exports Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def export(body, options = {})
        space_id = options.delete(:space_id)
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_export",
          params: options.slice(),
          body: body
        )
      end

      # Imports Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def import(body, options = {})
        space_id = options.delete(:space_id)
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_import",
          params: options.slice(:createNewCopies, :overwrite),
          body: body
        )
      end

      # Resolve import errors from Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] space_id and query params
      # @return [Object] Parsed response
      def resolve_import_errors(body, options = {})
        space_id = options.delete(:space_id)
        request(
          http_method: :post,
          endpoint: "#{build_endpoint_with_space(space_id)}/_resolve_import_errors",
          params: options.slice(:createNewCopies),
          body: body
        )
      end

      # Verify that a saved object exists
      # @param type [String] Type of the saved object
      # @param id [String] Saved object id 
      # @param options [Object] space_id and query params
      # @return [Boolean] 
      def exists?(type, id, options)
        begin
          get_by_id(type, id, options).present?
        rescue ApiExceptions::NotFoundError
          false
        end
      end

      private

      def _validate_type(type)
        raise ArgumentError, "Type is not valid" unless TYPES.include?(type.to_sym)
      end

      def build_endpoint_with_space(space_id)
        if space_id.present?
          "s/#{space_id}/api/saved_objects"
        else
          "api/saved_objects"
        end
      end

    end
  end
end