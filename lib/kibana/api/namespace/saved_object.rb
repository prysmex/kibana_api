module Kibana
  module API
    
    module SavedObject
      # Proxy method for {SavedObjectClient}, available in the receiving object
      def saved_object
        @saved_object ||= SavedObjectClient.new(self)
      end
    end

    class SavedObjectClient < BaseClient

      include Kibana::API::Spaceable

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

      # Retrieves a single Kibana saved object 
      # @param id [String] Id of the saved object
      # @param type [String] Type of the saved object
      # @param options [Object] query params
      # @return [Object] Parsed response
      def get_by_id(type, id, options = {})
        _validate_type(type)
        options = symbolize_keys(options).slice()

        request(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          params: options
        )
      end

      # Retrieves multiple Kibana saved object 
      # @param body [Array] Array of query objects (:type, :id, :fields)
      # @param options [Object] query params
      # @return [Object] Parsed response
      def bulk_get(body, options = {})
        body = body.map do |obj|
          _validate_type(obj[:type])
          symbolize_keys(obj).slice(:type, :id, :fields)
        end
        options = symbolize_keys(options).slice()

        request(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_bulk_get",
          body: body,
          params: options
        )
      end

      # Retrieves multiple paginated Kibana saved objects
      # @param options [Object] query params (:type, :per_page, :page, :search, :default_search_operator, :search_fields, :fields, :sort_field, :has_reference, :filter)
      # @return [Object] Parsed response
      def find(options = {})
        options = symbolize_keys(options).slice(
          :type, :per_page, :page, :search, :default_search_operator, :search_fields, :fields, :sort_field, :has_reference, :filter
        )
        _validate_type(options[:type]) if options.key?(:type)

        request(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/saved_objects/_find",
          params: options
        )
      end

      # Creates a Kibana saved object 
      # @param type [String] Saved object type
      # @param body [Object] Saved object body (:attributes, :references, :initialNamespaces)
      # @param options [Object] id and query params (:overwrite)
      # @return [Object] Parsed response
      def create(type, body, options = {})
        _validate_type(type)
        id = options.delete(:id)
        body = symbolize_keys(body).slice(:attributes, :references, :initialNamespaces)
        options = symbolize_keys(options).slice(:overwrite)
        endpoint = if id
          "#{current_space_api_namespace}/saved_objects/#{type}/#{id}"
        else
          "#{current_space_api_namespace}/saved_objects/#{type}"
        end

        request(
          http_method: :post,
          endpoint: endpoint,
          params: options,
          body: body
        )
      end

      # Creates multiple Kibana saved object 
      # @param body [Array] Array of saved objects (:type, :id, :attributes, :references, :initialNamespaces, :version)
      # @param options [Object] query params (:overwrite)
      # @return [Object] Parsed response
      def bulk_create(body, options = {})
        body = body.map do |obj|
          _validate_type(obj[:type])
          symbolize_keys(obj).slice(:type, :id, :attributes, :references, :initialNamespaces, :version)
        end
        options = symbolize_keys(options).slice(:overwrite)

        request(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_bulk_create",
          params: options,
          body: body
        )
      end

      # Updates a Kibana saved object 
      # @param body [Object] Saved object body (:attributes, :references)
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param options [Object] query params
      # @return [Object] Parsed response
      def update(body, type, id, options = {})
        body = symbolize_keys(body).slice(:attributes, :references)
        options = symbolize_keys(options).slice()

        request(
          http_method: :put,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          params: options,
          body: body
        )
      end

      # Deletes a Kibana saved object 
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param options [Object] query params (:force)
      # @return [Object] Parsed response
      def delete(id, type, options = {})
        options = symbolize_keys(options).slice(:force)

        request(
          http_method: :delete,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          params: options
        )
      end

      # Exports Kibana saved object 
      # @param body [Object] Saved object body (:type, :objects, :includeReferencesDeep, :excludeExportDetails)
      # @param options [Object] query params
      # @return [Object] Parsed response
      def export(body, options = {})
        body = symbolize_keys(body).slice(:type, :objects, :includeReferencesDeep, :excludeExportDetails)
        options = symbolize_keys(options).slice()

        raw_request(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_export",
          params: options,
          body: body
        )
      end

      # Imports Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] query params (:createNewCopies, :overwrite)
      # @return [Object] Parsed response
      def import(body, options = {})
        options = symbolize_keys(options).slice(:createNewCopies, :overwrite)

        file = Tempfile.new(['foo', '.ndjson'])
        begin
          file.write(body)
          file.rewind
          io_file = Faraday::FilePart.new(file, 'json')
          request(
            http_method: :post,
            endpoint: "#{current_space_api_namespace}/saved_objects/_import",
            params: options,
            body: {
              file: io_file
            },
            multipart: true
          )
        ensure
           file.close
           file.unlink
        end
      end

      # Resolve import errors from Kibana saved object 
      # @param body [Object] Saved object body
      # @param options [Object] query params (:createNewCopies)
      # @return [Object] Parsed response
      def resolve_import_errors(body, options = {})
        options = symbolize_keys(options).slice(:createNewCopies)
        
        request(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_resolve_import_errors",
          params: options,
          body: body
        )
      end

      # Verify that a saved object exists
      # @param type [String] Type of the saved object
      # @param id [String] Saved object id 
      # @param options [Object] query params (:savedObjectTypes)
      # @return [Boolean] 
      def exists?(type, id, options)
        options = symbolize_keys(options).slice(:savedObjectTypes)
        begin
          get_by_id(type, id, options).present?
        rescue Kibana::Transport::ApiExceptions::NotFoundError
          false
        end
      end

      def related_objects(type, id, options = {})
        _validate_type(type)

        request(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/kibana/management/saved_objects/relationships/#{type}/#{id}",
          params: options
        )
      end

      # counts({typesToInclude: [:visualization]})
      # @param body [Object] (:typesToInclude)
      # @return [Object]
      def counts(body)
        request(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/kibana/management/saved_objects/scroll/counts",
          body: body
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
      # @param options [Object] find params (same whitelist as find method)
      # @param parent_type [Symbol] the type of the parent object
      # @return [Array] of saved objects
      def find_orphans(options = {}, parent_type)
        # raise ArgumentError, "options[:type] must be an array of valid types" unless options[:type].is_a? ::Array

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

      # @param [String] title of the index pattern, not the id
      # @return [Object] a hash containing all fields under 'fields' key
      def fields_for_index_pattern(pattern, meta_fields=[:_source, :_id, :_type, :_index, :_score])
        data = request(
          http_method: :get,
          endpoint: '/api/index_patterns/_fields_for_wildcard',
          params: {
            pattern: pattern,
            meta_fields: meta_fields
          }
        )
        #add defaults
        data['fields'] = data['fields'].map do |field|
          field.merge({'count' => 0, 'scripted' => false})
        end
        data
      end

      def refresh_index_pattern!(id)
        index_pattern = get_by_id(:'index-pattern', id)
        current_fields = JSON.parse(index_pattern['attributes']['fields'])
        scripted_fields = current_fields.select do |f|
          f['scripted']
        end
        new_fields = fields_for_index_pattern(index_pattern['attributes']['title'])['fields']
        index_pattern['attributes']['fields'] = (scripted_fields + new_fields).to_json
        update({attributes: index_pattern['attributes']}, :'index-pattern', id)
      end

      private

      def _validate_type(types)
        types = types.is_a?(::Array) ? types : [types]
        types.each do |type|
          if !TYPES.include?(type.to_sym)
            raise ArgumentError, "SavedObject type '#{type}' is not valid"
          end
        end
      end

    end

  end
end