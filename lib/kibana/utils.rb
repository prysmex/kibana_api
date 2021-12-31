require 'json'

module Kibana
  module Utils

    #
    # @todo improve arguments
    #
    def self.build_dashboard(title, options = {})
      references = options.delete(:references) || []
      description = options.delete(:description) || ''
      panelsJSON = options.delete(:panelsJSON) || {}
      optionsJSON = options.delete(:optionsJSON) || {}
      timeRestore = options.delete(:timeRestore) || false

      options.merge({
        type: 'dashboard',
        references: references,
        attributes: {
          title: title,
          description: description,
          panelsJSON: panelsJSON.to_json,
          optionsJSON: optionsJSON.to_json,
          timeRestore: timeRestore,
          # 'kibanaSavedObjectMeta'
        }
      })
    end

    # Parses an ndjson exported string
    #
    # @param [String] export
    # @return [Array]
    def self.parse_ndjson(export)
      export.lines.map{|l| JSON.parse(l) }
    end

    # Builds an ndjson string
    #
    # @param array [Array<Hash>]
    # @return [String]
    def self.to_ndjson(array)
      array.map(&:to_json).join("\n")
    end
    
  end
end