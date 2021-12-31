module Kibana
  
  # Backing class for a Kibana Dashboard document, which hash the following structure
  #
  # {
  #   "attributes"=>{
  #     "description"=>"Empty template dashboard",
  #     "hits"=>0,
  #     "kibanaSavedObjectMeta"=>{
  #       "searchSourceJSON"=>"{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
  #     },
  #     "optionsJSON"=>"{\"useMargins\":true,\"syncColors\":false,\"hidePanelTitles\":false}",
  #     "panelsJSON"=>"[]",
  #     "timeRestore"=>false,
  #     "title"=>"empty",
  #     "version"=>1
  #   },
  #   "coreMigrationVersion"=>"7.16.2",
  #   "id"=>"fce26b20-6695-11ec-9837-3b6567a4e168",
  #   "migrationVersion"=>{
  #     "dashboard"=>"7.16.0"
  #   },
  #   "references"=>[],
  #   "type"=>"dashboard",
  #   "updated_at"=>"2021-12-26T21:51:32.061Z",
  #   "version"=>"WzQ2MDE5LDNd"
  # }
  #
  class Dashboard

    DASHBOARD_MAX_WIDTH = 48

    # To handle objects inside the 'panelsJSON' array, we use this struct.
    #
    # {
    #   'version': '7.16.2',
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
    #     'hidePanelTitles': true
    #   },
    #   'title': 'Some dashboard specific title',
    #   'panelRefName': "panel_0bbdf49d-40e5-485c-9977-29d3293bc2d6"
    # }
    # 
    GRID_DATA = Struct.new(:x, :y, :w, :h, :i, keyword_init: true) do
      # Distance of right side of panel to left side of dashboard
      #
      # @return [Integer]
      def x2
        self.x + self.w unless self.x.nil? || self.w.nil?
      end

      # Distance of right side of panel to left side of dashboard
      #
      # @return [Integer]
      def y2
        self.y + self.h unless self.y.nil? || self.h.nil?
      end
    end

    PanelObject = Struct.new(:version, :type, :title, :gridData, :panelIndex, :embeddableConfig, :panelRefName, keyword_init: true) do
      def initialize(**args)
        args['gridData'] = GRID_DATA.new(**(args['gridData'] || {}))
        super(**args)
      end
    end
  
    attr_reader :dashboard
  
    def initialize(dashboard)
      self.dashboard = dashboard
    end
  
    # @param [Hash] dashboard object
    # @return [Hash]
    def dashboard=(dashboard)
      @dashboard = dashboard
    end

    # Gets a value from the dashboard's 'attributes' key
    def get_attribute(attribute)
      @dashboard&.dig('attributes', attribute)
    end

    # sets a value on the dashboard's 'attributes' key
    def set_attribute(attribute, value)
      SuperHash::Utils.bury(@dashboard, 'attributes', attribute, value) if @dashboard
    end
  
    # Parses each object inside the 'panelsJSON' key into a PanelObject struct
    #
    # @return [Hash]
    def parsed_panels_json
      JSON.parse(self.get_attribute('panelsJSON')).map{|p| PanelObject.new(**p) }
    end
  
    # Retrieves the smallest x coordinate of all objects inside the 'panelsJSON' key
    #
    # @return [Integer]
    def min_x
      parsed_panels_json.min_by{|i| i.gridData.x }&.gridData.x || 0
    end
  
    # Retrieves the largest x coordinate of all objects inside the 'panelsJSON' key
    #
    # @return [Integer]
    def max_x
      parsed_panels_json.max_by{|i| i.gridData.x2 }&.gridData.x2 || 0
    end
  
    # Retrieves the smallest y coordinate of all objects inside the 'panelsJSON' key
    #
    # @return [Integer]
    def min_y
      parsed_panels_json.min_by{|i| i.gridData.y }&.gridData.y || 0
    end
  
    # Retrieves the largest y coordinate of all objects inside the 'panelsJSON' key
    #
    # @return [Integer]
    def max_y
      parsed_panels_json.max_by{|i| i.gridData.y2 }&.gridData.y2 || 0
    end
  
    # Builds a matrix N x M where N is the number of the rows and M is the number of columns
    # The value of the element represents the amount of visualizations on it. (0 => empty)
    #
    # @return [Array] matrix of array
    def dashboard_matrix
      matrix = Array.new(max_y) { Array.new(DASHBOARD_MAX_WIDTH) { 0 } }

      parsed_panels_json.each do |obj|
        y1 = obj.gridData.y
        h = obj.gridData.h
        x1 = obj.gridData.x
        x2 = obj.gridData.x2

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
    # be fitted
    #
    # @param w [Integer]
    # @param h [Integer]
    # @param start_position
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
  
    # Adds a visualization reference to the dashboard by
    #
    # - 1) adding reference to 'references'
    # - 2) add object to panelsJSON (position, configuration, etc...)
    # @param x [Integer] x coodinate, left to left distance
    # @param y [Integer] y coordinate, top to top distance
    # @param w [Integer] panel width
    # @param h [Integer] panel height
    # @param i [String]
    # @param reference_id [String]
    # @param title [String]
    # @return [void]
    def insert_visualization_at(x:, y:, w:, h:, i:, reference_id:, title:)
      parsed_panels_json = self.parsed_panels_json
  
      return false if parsed_panels_json.find{|i| i['panelIndex'] == i}
  
      # add panel json
      panel_hash = {
        # 'version': '',
        'type': 'visualization',
        'gridData': {
          'x': x,
          'y': y,
          'w': w,
          'h': h,
          'i': i
        },
        'panelIndex': i,
        'embeddableConfig': {
          'enhancements': {
            'title': title,
          },
          'hidePanelTitles': !title
        },
        'title': title,
        'panelRefName': "panel_#{i}"
      }
      parsed_panels_json.push(panel_hash)
      self.set_attribute('panelsJSON', parsed_panels_json.to_json)
  
      # add reference
      @dashboard['references'].push({
        'id': reference_id,
        'name': "#{i}:panel_#{i}",
        'type': 'visualization'
      })
    end

    # Adds a visualization on the first available space in the grid
    #
    # @param w [Integer] panel width
    # @param h [Integer] panel height
    # @param i [String]
    # @param title [String]
    # @param reference_id [String]
    # @return [void]
    def add_visualization(w:, h:, i:, title:, reference_id:)
      x,y = self.get_available_coordinates(w,h)
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

    # Appends a filter to a dashboard object.
    # @param key [String]
    # @param type [String]
    # @param value [String|Integer]
    # @param index_pattern_id [String]
    # @return mutated dashboard with appended filter
    def append_filter(key, type, value, index_pattern_id)
      dashboard = self.dashboard
      dashboard_filter = JSON.parse(dashboard['attributes']['kibanaSavedObjectMeta']['searchSourceJSON'])
      filter_size = dashboard_filter['filter'].size
      index_ref_name = "kibanaSavedObjectMeta.searchSourceJSON.filter[#{filter_size}].meta.index"
      filter = case type
      when 'is', 'is_not'
        value = value.to_s
        {
          'meta' => {
            'alias' => nil,
            'negate' => type == 'is_not',
            'disabled' => false,
            'type' => 'phrase',
            'key' => key,
            'params' => {
              'query' => value
            },
            'indexRefName' => index_ref_name
          },
          'query' => { 'match_phrase' => { "#{key}" => value } },
          '$state' => {
            'store' => 'appState'
          }
        }
      end
      dashboard_filter['filter'].push(filter)
      dashboard['attributes']['kibanaSavedObjectMeta']['searchSourceJSON'] = dashboard_filter.to_json
      dashboard['references'].push({
        'name' => index_ref_name,
        'type' => 'index-pattern',
        'id' => index_pattern_id
      })
      dashboard
    end
  
    # 1) remove reference from 'references'
    # 2) add object to panelsJSON
    def remove_visualization(id)
      reference = @dashboard['references'].find{|r| r['id'] == id }
      @dashboard['references'] = @dashboard['references'] - [reference]

      i = reference['name'].match(/panel_.*/).to_s
      parsed_panels_json = self.parsed_panels_json
      @dashboard.panelsJSON = parsed_panels_json.reject{|r| r['gridData']['i'] == i }.to_json
    end
  
    # @param id [String] id of tag
    # @return [Hash] added reference
    def add_tag(id)
      return false if @dashboard['references'].find{|i| i['id'] == id}
      @dashboard['references'].push({
        'id': "#{id}",
        'name': "tag-#{id}",
        'type': 'tag'
      })
    end
  
    # @param id [String] id of tag to remove
    # @param [Array] references
    def remove_tag(id)
      @dashboard['references'] = @dashboard['references'].reject{|i| i['id'] == id}
    end
  
    # @return [Array] filtered references
    def remove_all_tags
      @dashboard['references'] = @dashboard['references'].reject{|i| i['type'] == 'tag'}
    end
  
  end
end