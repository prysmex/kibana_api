module Kibana
  module API
    class SavedObjectClient < Client

      attr_reader :space_id

      TYPES = [
        :config,
        :'index-pattern',
        :visualization,
        :'timelion-sheet',
        :search,
        :dashboard,
        :url,
        :query,
        :map,
        :'canvas-element',
        :'canvas-workpad',
        :'canvas-workpad-template',
        :lens,
        :'infrastructure-ui-source',
        :'metrics-explorer-view',
        :'inventory-view'
      ].freeze

      def with_space(space_id)
        prev_space = @space_id
        @space_id = space_id
        return yield(space_id)
      ensure
        @space_id = prev_space
      end

      def each_space(&block)
        return_value = {}
        _defined_spaces.each do |space|
          return_value[space] = with_space(space, &block)
        end
        return_value
      end

      # Retrieves a single Kibana saved object 
      # @param id [String] Id of the saved object
      # @param type [String] Type of the saved object
      # @param options [Object] query params
      # @return [Object] Parsed response
      def get_by_id(type, id, options = {})
        _validate_type(type)
        request(
          http_method: :get,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/#{type}/#{id}",
          params: options.slice()
        )
      end

      # Retrieves multiple Kibana saved object 
      # @param body [Array] Array of query objects
      # @param options [Object] query params
      # @return [Object] Parsed response
      def bulk_get(body, options = {})
        body = body.map do |obj|
          _validate_type(obj[:type])
          obj.slice(:type, :id, :fields)
        end
        request(
          http_method: :post,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/_bulk_get",
          body: body,
          params: options.slice()
        )
      end

      # Retrieves multiple paginated Kibana saved objects
      # @param options [Object] query params
      # @return [Object] Parsed response
      def find(options = {})
        if options.key?(:type)
          if options[:type].is_a?(::Array)
            options[:type].each{|type| _validate_type(type) }
          else
            _validate_type(options[:type]) if options.key?(:type)
          end
        end
        request(
          http_method: :get,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/_find",
          params: options.slice(:type, :per_page, :page, :search, :default_search_operator, :search_fields, :fields, :sort_field, :has_reference, :filter)
        )
      end

      # Creates a Kibana saved object 
      # @param type [String] Saved object type
      # @param body [Object] Saved object body
      # @param options [Object] id and query params
      # @return [Object] Parsed response
      def create(type, body, options = {})
        _validate_type(type)
        id = options.delete(:id)
        endpoint = if id
          "#{api_namespace_for_space(@space_id)}/saved_objects/#{type}/#{id}"
        else
          "#{api_namespace_for_space(@space_id)}/saved_objects/#{type}"
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
      # @param options [Object] query params
      # @return [Object] Parsed response
      def bulk_create(body, options = {})
        body = body.map do |obj|
          _validate_type(obj[:type])
          obj.slice(:type, :id, :attributes, :references, :initialNamespaces, :version)
        end
        request(
          http_method: :post,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/_bulk_create",
          params: options.slice(:overwrite),
          body: body
        )
      end

      # Updates a Kibana saved object 
      # @param body [Object] Saved object body
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param options [Object] query params
      # @return [Object] Parsed response
      def update(body, type, id, options = {})
        request(
          http_method: :put,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/#{type}/#{id}",
          params: options.slice(),
          body: body.slice(:attributes, :references),
        )
      end

      # Deletes a Kibana saved object 
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param options [Object] query params
      # @return [Object] Parsed response
      def delete(id, type, options = {})
        request(
          http_method: :delete,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/#{type}/#{id}",
          params: options.slice(:force)
        )
      end

      # Exports Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] query params
      # @return [Object] Parsed response
      def export(body, options = {})
        request(
          http_method: :post,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/_export",
          params: options.slice(),
          body: body
        )
      end

      # Imports Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] query params
      # @return [Object] Parsed response
      def import(body, options = {})
        request(
          http_method: :post,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/_import",
          params: options.slice(:createNewCopies, :overwrite),
          body: body
        )
      end

      # Resolve import errors from Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] query params
      # @return [Object] Parsed response
      def resolve_import_errors(body, options = {})
        request(
          http_method: :post,
          endpoint: "#{api_namespace_for_space(@space_id)}/saved_objects/_resolve_import_errors",
          params: options.slice(:createNewCopies),
          body: body
        )
      end

      # Verify that a saved object exists
      # @param type [String] Type of the saved object
      # @param id [String] Saved object id 
      # @param options [Object] query params
      # @return [Boolean] 
      def exists?(type, id, options)
        begin
          get_by_id(type, id, options).present?
        rescue ApiExceptions::NotFoundError
          false
        end
      end

      def related_objects(type, id, options = {})
        _validate_type(type)
        request(
          http_method: :get,
          endpoint: "#{api_namespace_for_space(@space_id)}/kibana/management/saved_objects/relationships/#{type}/#{id}",
          params: options.slice(:savedObjectTypes)
        )
      end

      # counts({typesToInclude: [:visualization]})
      def counts(body)
        request(
          http_method: :post,
          endpoint: "#{api_namespace_for_space(@space_id)}/kibana/management/saved_objects/scroll/counts",
          body: body.slice(:typesToInclude)
        )
      end

      def find_all_pages(options = {}, max_pages = 100)
        options.reverse_merge!({per_page: 100, fields: []})
        all_saved_objects = []
        page = 1

        while page < max_pages  do
          data = find(options.merge({
            page: page
          }))
          page += 1
          break if data['saved_objects'].size == 0
          yield data if block_given?
          all_saved_objects.concat(data['saved_objects'])
        end
        all_saved_objects
      end

      #example to find orphan visualizations find_all_orphans({type: [:visualization], fields: [:title]}, :dashboard)
      def find_orphans(options = {}, parent_type)
        raise ArgumentError, "options[:type] must be an array of valid types" unless options[:type].is_a? ::Array

        # get all objects
        all_objects = find_all_pages(options)

        #get all parents
        all_parents = find_all_pages({type: [parent_type]})

        #get all parents children
        all_parents_children = all_parents.inject([]) do |accum, parent|
          related_objects = related_objects(parent_type, parent['id'], {savedObjectTypes: options[:type]})
          accum.concat(related_objects)
        end

        #get orphans
        all_objects.select do |obj|
          all_parents_children.find{|v| v['id'] == obj['id']}.nil?
        end
      end

      private

      def _validate_type(type)
        raise ArgumentError, "SavedObject type '#{type}' is not valid" unless TYPES.include?(type.to_sym)
      end

      def api_namespace_for_space(@space_id)
        if space_id.nil?
          "api"
        else
          "s/#{space_id}/api"
        end
      end

    end
  end
end