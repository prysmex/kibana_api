# frozen_string_literal: true

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

      TYPES = %i[
        tag
        config
        index-pattern
        visualization
        timelion-sheet
        search
        dashboard
        url
        query
        map
        canvas-element
        canvas-workpad
        canvas-workpad-template
        lens
        infrastructure-ui-source
        metrics-explorer-view
        inventory-view
      ].freeze

      # Retrieves a single Kibana saved object
      #
      # @param id [String]
      # @param type [String]
      # @param params [Hash] query params
      # @return [Hash]
      def get(type:, id:, **args)
        _validate_type(type)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}"
        ))
      end

      # Retrieves multiple Kibana saved objects
      #
      # @param body [Array<Hash>]
      #   @option body[] [String] :type
      #   @option body[] [String] :id
      #   @option body[] [Array<String>] :fields
      #   @option body[] [Array<String>] :namespaces
      # @param params [Hash] query params
      # @return [Hash]
      def bulk_get(body:, **args)
        body = body.map do |obj|
          _validate_type(obj[:type])
          symbolize_keys(obj).slice(:type, :id, :fields)
        end

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_bulk_get",
          body:
        ))
      end

      # Retrieves paginated Kibana saved objects
      #
      # @param params [Hash] query params
      #   @option params [String] :type
      #   @option params [Integer] :per_page
      #   @option params [Integer] :page
      #   @option params [String] :search
      #   @option params [String] :default_search_operator
      #   @option params [Array] :search_fields
      #   @option params [Array] :fields
      #   @option params [String] :sort_field
      #   @option params [Hash] :has_reference, type and ID
      #   @option params [String] :filter
      #   @option params [String] :aggs
      # @return [Hash]
      def find(params:, **args)
        params = symbolize_keys(params).slice(
          :type, :per_page, :page, :search, :default_search_operator,
          :search_fields, :fields, :sort_field, :has_reference, :filter
        )
        _validate_type(params[:type]) if params.key?(:type)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/saved_objects/_find",
          params:
        ))
      end

      # Iterates pages for a find request, yields a block to give access to response
      #
      # @Todo use the scroll api
      #
      # @param params (same as #find)
      # @param max_pages [Integer]
      # @return [Array]
      def find_each_page(params:, max_pages: 100, **args)
        params.reverse_merge!({per_page: 100})
        page = 1
        data_array = []

        while page < max_pages
          data = find(
            **args.merge({
              params: params.merge({page:})
            })
          )
          parsed_data = data.is_a?(::Hash) ? data : JSON.parse(data)
          page += 1
          break if parsed_data['saved_objects'].empty?

          yield(data, parsed_data) if block_given?
          data_array.push(data)
        end

        data_array
      end

      # Creates a Kibana saved object
      #
      # @param type [String]
      # @param body [Hash]
      #   @option body [Hash] :attributes
      #   @option body [Array<Hash>] :references
      #   @option body [Array<String>] :initialNamespaces
      # @param params [Hash] query params
      #   @option params [Boolean] :overwrite
      # @param id [String]
      # @return [Hash]
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
          endpoint:,
          params:,
          body:
        ))
      end

      # Creates multiple Kibana saved object
      #
      # @param body [Array] Array of saved objects
      #   @option body[] [String] :type
      #   @option body[] [String] :id
      #   @option body[] [Hash] :attributes
      #   @option body[] [Array<Hash>] :references
      #   @option body[] [Array<String>] :initialNamespaces
      #   @option body[] [Integer] :version
      # @param params [Hash]
      #   @option params [Boolean] :overwrite
      # @return [Hash] containing 'saved_objects' key
      def bulk_create(body:, params: {}, **args)
        body = body.map do |obj|
          _validate_type(obj[:type])
          symbolize_keys(obj).slice(:type, :id, :attributes, :references, :initialNamespaces, :version)
        end
        params = symbolize_keys(params).slice(:overwrite)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_bulk_create",
          params:,
          body:
        ))
      end

      # Updates a Kibana saved object
      #
      # @param type [String]
      # @param id [String]
      # @param body [Hash] Saved object body
      #   @option body [Hash] :attributes
      #   @option body [Array] :references
      #   @option body [] :upsert
      # @param params [Hash] query params
      # @return [Hash]
      def update(type:, id:, body:, **args)
        body = symbolize_keys(body).slice(:attributes, :references, :upsert)

        request(**args.merge(
          http_method: :put,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          body:
        ))
      end

      # Deletes a Kibana saved object
      #
      # @param type [String]
      # @param id [String]
      # @param params [Hash] query params
      #   @option params [Boolean] :force
      # @return [NilClass]
      def delete(id:, type:, params: {}, **args)
        params = symbolize_keys(params).slice(:force)

        request(**args.merge(
          http_method: :delete,
          endpoint: "#{current_space_api_namespace}/saved_objects/#{type}/#{id}",
          params:
        ))
      end

      # Deletes all objects that match
      # @note Accepts same arguments as #find
      #
      # @return [void]
      def delete_by_find(**args)
        find_each_page(**args) do |data|
          data['saved_objects'].each do |saved_object|
            delete(id: saved_object['id'], type: saved_object['type'])
          end
        end
      end

      # Exports Kibana saved object
      #
      # @param body [Hash] Saved object body
      #   @option body [Array] :type
      #   @option body [Array] :objects
      #   @option body [Boolean] :includeReferencesDeep
      #   @option body [Boolean] :excludeExportDetails
      # @return [Hash]
      def export(body:, **args)
        body = symbolize_keys(body).slice(:type, :objects, :includeReferencesDeep, :excludeExportDetails)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/saved_objects/_export",
          body:,
          raw: true
        ))
      end

      # Imports Kibana saved object
      #
      # @param body [Hash]
      # @param params [Hash] query params
      #   @option params [Boolean] :createNewCopies
      #   @option params [Boolean] :overwrite
      # @return [Hash]
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
            params:,
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

      # # Resolve import errors from Kibana saved object
      # #
      # # @param body [Hash] Same given to #import API
      # # @param params [Hash] query params
      # #   @option params [Boolean] :createNewCopies
      # # @return [Hash] Parsed response
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
      #
      # @param type [String]
      # @param id [String]
      # @param options [Hash] query params
      # @return [Boolean]
      def exists?(**args)
        get(**args).present?
      rescue Kibana::Transport::ApiExceptions::NotFoundError
        false
      end

      # Returns related saved_objects for a saved_object
      #
      # @param type [String]
      # @param id [String]
      # @param params [Hash] query params
      #   @option params [Array<String>] :savedObjectTypes
      # @return [ToDo]
      def related_objects(type:, id:, params: {}, **args)
        params = symbolize_keys(params).slice(:savedObjectTypes)
        _validate_type(type)

        request(**args.merge(
          http_method: :get,
          endpoint: "#{current_space_api_namespace}/kibana/management/saved_objects/relationships/#{type}/#{id}",
          params:
        ))
      end

      # Get count of types of visualizations
      #
      # @param body [Hash] query params
      #   @option body [Array<String>] :typesToInclude
      # @return [Object]
      def counts(body:, **args)
        body = symbolize_keys(body).slice(:typesToInclude)

        request(**args.merge(
          http_method: :post,
          endpoint: "#{current_space_api_namespace}/kibana/management/saved_objects/scroll/counts",
          body:
        ))
      end

      # Returns al saved_objects that hash no parent with another type
      # An example would be to find all visualizations that are not
      # related to any dashboard
      #
      # @example to find orphan visualizations from dashboards
      #
      #   find_all_orphans(params: {type: [:visualization], fields: [:title]}, parent_type: :dashboard)
      #
      # @param params [Hash] (same as #find method)
      # @param parent_type [Symbol] the type of the parent object
      # @return [Array] of saved objects
      def find_orphans(parent_type:, params: {})
        raise ArgumentError.new('params[:type] must be an array of valid types') unless params[:type].is_a?(::Array)

        # get all objects
        all_objects = find_each_page({params:}).map do |resp|
          resp['saved_objects']
        end.flatten

        # get all parents
        all_parents = find_each_page({params: {type: [parent_type]}}).map do |resp|
          resp['saved_objects']
        end.flatten

        # get all parents children
        all_parents_children = all_parents.inject([]) do |accum, parent|
          accum.concat(
            related_objects({
              type: parent_type,
              id: parent['id'],
              params: {savedObjectTypes: params[:type]}
            })
          )
        end

        # get orphans
        all_objects.select do |obj|
          all_parents_children.find { |v| v['id'] == obj['id'] }.nil?
        end
      end

      # Get kibana fields for an index pattern
      #
      # @param [String] title of the index pattern, not the id
      # @return [Object] a hash containing all fields under 'fields' key
      def fields_for_index_pattern(pattern, meta_fields = %i[_source _id _type _index _score])
        request(
          http_method: :get,
          endpoint: '/api/index_patterns/_fields_for_wildcard',
          params: {
            pattern:,
            meta_fields:
          }
        )
      end

      private

      def _validate_type(types)
        types = [types] unless types.is_a?(::Array)
        types.each do |type|
          raise ArgumentError.new("SavedObject type '#{type}' is not valid") unless TYPES.include?(type.to_sym)
        end
      end

    end

  end
end