module Kibana
  module API
    
    module SavedObject
      # Proxy method for {SavedObjectClient}, available in the receiving object
      def saved_object
        # Thread.current['saved_object_client'] ||= SavedObjectClient.new(self)
        @saved_object = SavedObjectClient.new(self)
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
      # @param params [Object] query params
      # @return [Object] Parsed response
      def get(type:, id:, **args)
        _validate_type(type)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}"
        ))
      end

      # Retrieves multiple Kibana saved object 
      # @param body [Array] Array of query objects (:type, :id, :fields)
      # @param params [Object] query params
      # @return [Object] Parsed response
      def bulk_get(body:, **args)
        body = body.map do |obj|
          _validate_type(obj[:type])
          symbolize_keys(obj).slice(:type, :id, :fields)
        end

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_bulk_get",
          body: body
        ))
      end

      # Retrieves multiple paginated Kibana saved objects
      # @param params [Object] query params (:type, :per_page, :page, :search, :default_search_operator, :search_fields, :fields, :sort_field, :has_reference, :filter)
      # @return [Object] Parsed response
      def find(params:, **args)
        params = symbolize_keys(params).slice(
          :type, :per_page, :page, :search, :default_search_operator, :search_fields, :fields, :sort_field, :has_reference, :filter
        )
        _validate_type(params[:type]) if params.key?(:type)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/saved_objects/_find",
          params: params
        ))
      end

      # iterates pages for a find request, yields a block to give access to response
      # should this use the scroll api?
      def find_each_page(params:, max_pages: 100, **args)
        params.reverse_merge!({per_page: 100})
        page = 1
        data_array = []

        while page < max_pages  do
          data = find(**args.merge({
            params: params.merge({page: page})
          }))
          parsed_data = data.is_a?(::Hash) ? data : JSON.parse(data)
          page += 1
          break if parsed_data['saved_objects'].size == 0
          yield(data, parsed_data) if block_given?
          data_array.push(data)
        end

        data_array
      end

      # Creates a Kibana saved object 
      # @param type [String] Saved object type
      # @param body [Object] Saved object body (:attributes, :references, :initialNamespaces)
      # @param params [Object] query params (:overwrite)
      # @return [Object] Parsed response
      def create(type:, body:, params: {}, id: nil, **args)
        _validate_type(type)
        body = symbolize_keys(body).slice(:attributes, :references, :initialNamespaces)
        params = symbolize_keys(params).slice(:overwrite)
        endpoint = if id
          "#{current_space_api_namespace}/saved_objects/#{type}/#{id}"
        else
          "#{current_space_api_namespace}/saved_objects/#{type}"
        end

        request(**args.merge(
          http_method: :post,
          endpoint: endpoint,
          params: params,
          body: body
        ))
      end

      # Creates multiple Kibana saved object 
      # @param body [Array] Array of saved objects (:type, :id, :attributes, :references, :initialNamespaces, :version)
      # @param params [Object] query params (:overwrite)
      # @return [Object] Parsed response
      def bulk_create(body:, params: {}, **args)
        body = body.map do |obj|
          _validate_type(obj[:type])
          symbolize_keys(obj).slice(:type, :id, :attributes, :references, :initialNamespaces, :version)
        end
        params = symbolize_keys(params).slice(:overwrite)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_bulk_create",
          params: params,
          body: body
        ))
      end

      # Updates a Kibana saved object 
      # @param body [Object] Saved object body (:attributes, :references)
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param params [Object] query params
      # @return [Object] Parsed response
      def update(type:, id:, body:, **args)
        body = symbolize_keys(body).slice(:attributes, :references)

        request(**args.merge(
          http_method: :put,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          body: body
        ))
      end

      # Deletes a Kibana saved object 
      # @param type [String] Saved object type
      # @param id [String] Saved object id 
      # @param params [Object] query params (:force)
      # @return [Object] Parsed response
      def delete(id:, type:, params: {}, **args)
        params = symbolize_keys(params).slice(:force)

        request(**args.merge(
          http_method: :delete,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          params: params
        ))
      end

      # def delete_by_find
      #   #TODO
      # end

      # Exports Kibana saved object 
      # @param body [Object] Saved object body (:type, :objects, :includeReferencesDeep, :excludeExportDetails)
      # @return [Object] Parsed response
      def export(body:, **args)
        body = symbolize_keys(body).slice(:type, :objects, :includeReferencesDeep, :excludeExportDetails)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_export",
          body: body,
          raw: true
        ))
      end

      # Imports Kibana saved object 
      # @param body [Object] Saved object body
      # @param params [Object] query params (:createNewCopies, :overwrite)
      # @return [Object] Parsed response
      def import(body:, params: {}, **args)
        params = symbolize_keys(params).slice(:createNewCopies, :overwrite)

        file = Tempfile.new(['foo', '.ndjson'])
        begin
          file.write(body)
          file.rewind
          io_file = Faraday::FilePart.new(file, 'json')
          request(**args.merge(
            http_method: :post,
            endpoint: "#{current_space_api_namespace}/saved_objects/_import",
            params: params,
            body: {
              file: io_file
            },
            raw_body: true,
            multipart: true
          ))
        ensure
           file.close
           file.unlink
        end
      end

      # Resolve import errors from Kibana saved object 
      # @param body [Object] Saved object body
      # @param params [Object] query params (:createNewCopies)
      # @return [Object] Parsed response
      # def resolve_import_errors(body:, params: {}, **args)
      #   params = symbolize_keys(params).slice(:createNewCopies)
      #   body = symbolize_keys(body).slice(:file, :retries)
        
      #   request(**args.merge(
      #     http_method: :post,
      #     endpoint: "#{current_space_api_namespace}/saved_objects/_resolve_import_errors",
      #     params: params,
      #     body: body,
      #     raw_body: true,
      #     multipart: true
      #   ))
      # end

      # Verify that a saved object exists
      # @param type [String] Type of the saved object
      # @param id [String] Saved object id 
      # @param options [Object] query params
      # @return [Boolean] 
      def exists?(**args)
        begin
          get(**args).present?
        rescue Kibana::Transport::ApiExceptions::NotFoundError
          false
        end
      end

      # savedObjectTypes: [:'index-pattern']
      def related_objects(type:, id:, params: {}, **args)
        params = symbolize_keys(params).slice(:savedObjectTypes)
        _validate_type(type)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/kibana/management/saved_objects/relationships/#{type}/#{id}",
          params: params
        ))
      end

      # counts({typesToInclude: [:visualization]})
      # @param body [Object] (:typesToInclude)
      # @return [Object]
      def counts(body:, **args)
        body = symbolize_keys(body).slice(:typesToInclude)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/kibana/management/saved_objects/scroll/counts",
          body: body
        ))
      end

      #example to find orphan visualizations find_all_orphans(params: {type: [:visualization], fields: [:title]}, parent_type: :dashboard)
      # @param params [Object] find params (same whitelist as find method)
      # @param parent_type [Symbol] the type of the parent object
      # @return [Array] of saved objects
      def find_orphans(params: {}, parent_type:)
        raise ArgumentError, "params[:type] must be an array of valid types" unless params[:type].is_a?(::Array)

        # get all objects
        all_objects = find_each_page({params: params}).map do |resp|
          resp['saved_objects']
        end.flatten

        #get all parents
        all_parents = find_each_page({params: {type: [parent_type]}}).map do |resp|
          resp['saved_objects']
        end.flatten

        #get all parents children
        all_parents_children = all_parents.inject([]) do |accum, parent|
          related_objects = related_objects({
            type: parent_type,
            id: parent['id'],
            params: {savedObjectTypes: params[:type]}
          })
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
        index_pattern = get(type: :'index-pattern', id: id)
        current_fields = JSON.parse(index_pattern['attributes']['fields'])
        scripted_fields = current_fields.select do |f|
          f['scripted']
        end
        new_fields = fields_for_index_pattern(
          index_pattern['attributes']['title']
        )['fields']
        index_pattern['attributes']['fields'] = (scripted_fields + new_fields).to_json
        update(
          body: {attributes: index_pattern['attributes']},
          type: :'index-pattern',
          id: id
        )
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