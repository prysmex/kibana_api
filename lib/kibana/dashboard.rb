require 'securerandom'

module Kibana
  module Dashboard

    # Backing class for a single object inside a dashboard's attributes.panelsJSON array
    # 
    # @note from version 8.1.1
    #
    # {
    #   'version': '8.1.1',
    #   'type': 'visualization',
    #   'gridData': {
    #     'x': 0,
    #     'y': 0,
    #     'w': 10,
    #     'h': 5,
    #     'i': 0bbdf49d-40e5-485c-9977-29d3293bc2d6
    #   },
    #   'panelIndex': 0bbdf49d-40e5-485c-9977-29d3293bc2d6,
    #   'embeddableConfig': {
    #     'enhancements': {},
    #     'hidePanelTitles': true,
    #     'savedVis': {}
    #   },
    #   'title': 'Some dashboard specific title',
    #   'panelRefName': "panel_0bbdf49d-40e5-485c-9977-29d3293bc2d6"
    # }
    #
    class PanelJSON < Hash
      include SuperHash::Hasher
      instance_variable_set('@allow_dynamic_attributes', true)

      # Distance of right side of panel to left side of dashboard
      #
      # @return [Integer]
      def x2
        grid_data = self['gridData']
        return if grid_data.nil? || grid_data['x'].nil? || grid_data['w'].nil?
        grid_data['x'] + grid_data['w']
      end

      # Distance of right side of panel to left side of dashboard
      #
      # @return [Integer]
      def y2
        grid_data = self['gridData']
        return if grid_data.nil? || grid_data['y'].nil? || grid_data['h'].nil?
        grid_data['y'] + grid_data['h']
      end

    end

    # Backing class for a Kibana Dashboard document, which hash the following structure
    #
    # @note from version 8.1.1
    #
    # {
    #   "attributes": {
    #     "description": "Empty template dashboard",
    #     "hits": 0,
    #     "kibanaSavedObjectMeta": {
    #       "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    #     },
    #     "optionsJSON": "{\"useMargins\":true,\"syncColors\":false,\"hidePanelTitles\":false}",
    #     "panelsJSON": "[]",
    #     "timeRestore": false,
    #     "title": "empty",
    #     "version": 1
    #   },
    #   "coreMigrationVersion": "8.1.1",
    #   "id": "fce26b20-6695-11ec-9837-3b6567a4e168",
    #   "migrationVersion": {
    #     "dashboard": "8.1.0"
    #   },
    #   "references": [],
    #   "type": "dashboard",
    #   "updated_at": "2021-12-26T21:51:32.061Z",
    #   "version": "WzQ2MDE5LDNd"
    # }
    #
    class Dashboard < Hash
      include SuperHash::Hasher
      instance_variable_set('@allow_dynamic_attributes', true)

      DASHBOARD_MAX_WIDTH = 48

      # Gets a value from the dashboard's 'attributes' key
      def get_attribute(attribute)
        self.dig('attributes', attribute)
      end

      # sets a value on the dashboard's 'attributes' key
      def set_attribute(attribute, value)
        SuperHash::Utils.bury(self, 'attributes', attribute, value)
      end
    
      # Parses each object inside the 'panelsJSON' key into a PanelJSON struct
      #
      # @return [Hash]
      def parsed_panels_json
        JSON.parse(self.get_attribute('panelsJSON')).map{|o| PanelJSON.new(o) }
      end

      ################
      # MATRIX UTILS #
      ################
    
      # Retrieves the smallest x coordinate of all objects inside the 'panelsJSON' key
      #
      # @return [Integer]
      def min_x
        parsed_panels_json.min_by{|i| i.dig('gridData', 'x') }&.dig('gridData', 'x') || 0
      end
    
      # Retrieves the largest x coordinate of all objects inside the 'panelsJSON' key
      #
      # @return [Integer]
      def max_x
        parsed_panels_json.max_by{|i| i.x2 }&.x2 || 0
      end
    
      # Retrieves the smallest y coordinate of all objects inside the 'panelsJSON' key
      #
      # @return [Integer]
      def min_y
        parsed_panels_json.min_by{|i| i.dig('gridData', 'y') }&.dig('gridData', 'y') || 0
      end
    
      # Retrieves the largest y coordinate of all objects inside the 'panelsJSON' key
      #
      # @return [Integer]
      def max_y
        parsed_panels_json.max_by{|i| i.y2 }&.y2 || 0
      end
    
      # Builds a matrix N x M where N is the number of the rows and M is the number of columns
      # The value of the element represents the amount of visualizations on it. (0 => empty)
      #
      # @return [Array] matrix of array
      def dashboard_matrix
        matrix = Array.new(max_y) { Array.new(DASHBOARD_MAX_WIDTH) { 0 } }

        parsed_panels_json.each do |obj|
          y1 = obj.dig('gridData', 'y')
          h = obj.dig('gridData', 'h')
          x1 = obj.dig('gridData', 'x')
          x2 = obj.x2

          rows = matrix.slice(y1, h)
          range = (x1...x2)
          rows.each do |row|
            row.map!.with_index{|a, i| range.include?(i) ? a + 1 : a }
          end
        end

        matrix
      end

      # Prints the matrix into console
      #
      # [0, 0, 1, 1, 1, 0 ...]
      # [0, 0, 1, 1, 1, 0 ...]
      # [0, 0, 1, 1, 1, 0 ...]
      #
      # @return [void]
      def print_dashboard_matrix
        dashboard_matrix.each{|i| puts i.to_s}
      end

      # Checks the following:
      #
      # - overlapping visualizations
      #
      # @return [Boolean]
      def valid_matrix?
        !dashboard_matrix.any? do |row|
          row.any?{|i| i > 1}
        end
      end

      # Sums the amount of empty spaces in the matrix
      #
      # @return [Integer] number of empty spaces
      def empty_spaces
        dashboard_matrix.reduce(0) do |acum, row|
          acum + row.inject(0){|a, e| e == 0 ? a + 1 : a }
        end
      end

      # For a given rectangle of size w and h, get the first available coordinates where it can
      # be fitted. By default, it searches for an available space starting from the top-left most coordinate,
      # but that can be changed using the 'start_position' param
      #
      # @param w [Integer]
      # @param h [Integer]
      # @param start_position [Symbol]
      # @return [Array] x,y coordinates
      def get_available_coordinates(w,h, start_position: :top_left)

        return [0, max_y] if empty_spaces < (w * h)

        coordinates = nil
        matrix = self.dashboard_matrix

        # rotate matrix if needed
        matrix = case start_position
        when :top_left
          matrix
        when :top_right
          matrix.map{|i| i.reverse }
        when :bottom_left
          matrix.reverse
        when :bottom_right
          matrix.reverse.map{|i| i.reverse }
        else
          raise ArgumentError.new("invalid start_position")
        end
        
        # find first available space
        matrix.each_with_index do |row, row_i|
          # skip row since not enought 0s
          next if row.select{|i| i == 0 }.size < w

          column_i = 0
          while column_i <= DASHBOARD_MAX_WIDTH
            if row[column_i] != 0
              column_i += 1
            else
              
              array = []
              row.slice(column_i, w).each do |a|
                break if a != 0
                array.push(a)
              end

              if array.size < w
                column_i += [array.size, 1].max #skip multiple columns
              elsif (1..w).all?{|i| matrix[row_i + i].nil? || !matrix[row_i + i].slice(column_i, w).include?(1) }
                coordinates = [column_i, row_i]
                break
              else
                column_i += 1
              end
            end
          end

          break if coordinates
        end

        # no fitting space was available
        return [0, max_y] if coordinates.nil?

        # de-rotate final coordinates
        case start_position
        when :top_left
          coordinates
        when :top_right
          [DASHBOARD_MAX_WIDTH - coordinates[0], coordinates[1]]
        when :bottom_left
          [coordinates[0], self.max_y - coordinates[1]]
        when :bottom_right
          [DASHBOARD_MAX_WIDTH - coordinates[0], self.max_y - coordinates[1]]
        end
      end

      # @todo
      #
      # def available_coordinates_at?()
      # end

      ##################
      # VISUALIZATIONS #
      ##################
    
      # Adds a visualization reference to the dashboard by
      #
      # - add object to 'panelsJSON' key (grid, title, etc...)
      # - adding reference to 'references'
      #
      # @note When inserting a visualization, it is not guaranteed that the matrix will be valid,
      #   for that, see #add_visualization
      #
      # @param x [Integer] x coodinate, left to left distance
      # @param y [Integer] y coordinate, top to top distance
      # @param w [Integer] panel width
      # @param h [Integer] panel height
      # @param reference_id [String] UUID of visualization
      # @param title [String]
      # @param panel_id [String] UUID, it must be the same in 'panelsJSON' and 'references'
      # @return [void]
      def insert_visualization_at(x:, y:, w:, h:, reference_id:, title:, panel_id: SecureRandom.uuid)
        parsed_panels_json = self.parsed_panels_json
    
        # return if visualization is already present in dashboard
        return false if parsed_panels_json.find{|i| i['panelIndex'] == panel_id}
    
        panel_hash = {
          # 'version': '',
          'type': 'visualization',
          'gridData': {
            'x': x,
            'y': y,
            'w': w,
            'h': h,
            'i': panel_id
          },
          'panelIndex': panel_id,
          'embeddableConfig': {
            'enhancements': {
              'title': title,
            },
            'hidePanelTitles': !title
          },
          'title': title,
          'panelRefName': "panel_#{panel_id}"
        }
        
        # set 'panelsJSON' key
        parsed_panels_json.push(panel_hash)
        self.set_attribute('panelsJSON', parsed_panels_json.to_json)
    
        # add reference to the dashboard 'references' key
        self['references'].push({
          'id': reference_id,
          'name': "#{panel_id}:panel_#{panel_id}",
          'type': 'visualization'
        })
      end

      # Adds a visualization on the first available space in the grid
      #
      # @param w [Integer] panel width
      # @param h [Integer] panel height
      # @param reference_id [String]
      # @param title [String]
      # @param panel_id [String] UUID, it must be the same in 'panelsJSON' and 'references'
      # @return [void]
      def add_visualization(w:, h:, reference_id:, title:, panel_id: SecureRandom.uuid, start_position: :top_left)
        x,y = self.get_available_coordinates(w,h, start_position: start_position)
        insert_visualization_at(
          x: x,
          y: y,
          w: w,
          h: h,
          i: i,
          reference_id: reference_id,
          title: title
        )
      end

      # def get_visualization
      # end

      # def get_visualization_at(x:, y:)
      # end

      # Removes a visualization by:
      #
      # - removing the reference from 'references'
      # - remove from panelsJSON
      #
      # @param id [String]
      def remove_visualization(id)
        reference = self['references'].find{|r| r['id'] == id }

        # remove from references
        self['references'] = self['references'] - [reference]

        # extract uuid
        i = reference['name'].match(/panel_.*/).to_s

        # remove from panelsJSON
        parsed_panels_json = self.parsed_panels_json
        new_panels_json = parsed_panels_json.reject{|r| r['gridData']['i'] == i }.to_json
        set_attribute('panelsJSON', new_panels_json)
      end

      # def remove_visualization_at
      # end

      # def move_visualization
      # end

      # Called when a visualization is removed/moved
      #
      # def update_matrix!
      # end

      ###########
      # FILTERS #
      ###########

      # Appends a filter to a dashboard object.
      #
      # @param key [String]
      # @param type [String] is, one_of, exist
      # @param value [String|Integer|Hash]
      # @param index_pattern_id [String]
      # @return mutated dashboard with appended filter
      def append_filter(key:, type:, value:, index_pattern_id:, negate: false, disabled: false, label: nil)
        dashboard_filter = JSON.parse(self['attributes']['kibanaSavedObjectMeta']['searchSourceJSON'])

        # filter position in dashboard (index)
        filter_count = dashboard_filter['filter'].size
        index_ref_name = "kibanaSavedObjectMeta.searchSourceJSON.filter[#{filter_count}].meta.index"

        # build base filter object
        filter = {
          "meta"=>{
            'field' => key,
            'alias' => label,
            "negate"=>negate,
            "disabled"=>disabled,
            "key"=>key,
            "indexRefName"=> index_ref_name
          },
          "$state"=>{
            "store"=>"appState"
          }
        }

        # set type, meta, query and field to filter hash
        case type
        when 'is'
          filter['meta']['type'] = 'phrase'
          filter['query'] = { 'match_phrase' => { "#{key}" => value } }
          filter['meta']['params'] = { 'query' =>  value.to_s }
        when 'one_of'
          filter['meta']['type'] = 'phrases'
          filter['query'] = {
            "bool" => {
              "should"=> value.map{|o| { "match_phrase"=>{ "#{key}"=> o } } },
              "minimum_should_match" => 1
            }
          }
          filter['meta']['params'] = value
        when 'exist'
          filter['meta']['type'] = 'exists'
          filter['query'] = { "exists"=>{ "field"=>"#{key}" } }
          filter['meta']['value'] = 'exists'
        when 'between'
          filter['meta']['field'] = key
          filter['meta']['type'] = 'range'
          filter['query'] = { "range"=>{ "#{key}"=> value } }
          filter['meta']['params'] = value
        else
          raise ArgumentError.new("invalid type #{type}")
        end

        # stringify and set to dashboard
        dashboard_filter['filter'].push(filter)
        self['attributes']['kibanaSavedObjectMeta']['searchSourceJSON'] = dashboard_filter.to_json

        # add reference to dashboard
        self['references'].push({
          'name' => index_ref_name,
          'type' => 'index-pattern',
          'id' => index_pattern_id
        })

        self
      end

      ###########
      # FILTERS #
      ###########
    
      # @param id [String] id of tag
      # @return [Hash] added reference
      def add_tag(id)
        return false if self['references'].find{|i| i['id'] == id}

        self['references'].push({
          'id': "#{id}",
          'name': "tag-#{id}",
          'type': 'tag'
        })
      end
    
      # @param id [String] id of tag to remove
      # @param [Array] references
      def remove_tag(id)
        self['references'] = self['references'].reject{|i| i['id'] == id}
      end
    
      # @return [Array] filtered references
      def remove_all_tags
        self['references'] = self['references'].reject{|i| i['type'] == 'tag'}
      end
    
    end
  end
end