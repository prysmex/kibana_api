# frozen_string_literal: true

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
        references:,
        attributes: {
          title:,
          description:,
          panelsJSON: Oj.dump(panelsJSON),
          optionsJSON: Oj.dump(optionsJSON),
          timeRestore:
          # 'kibanaSavedObjectMeta'
        }
      })
    end

    # Parses an ndjson exported string
    #
    # @param [String] export
    # @return [Array]
    def self.parse_ndjson(export)
      export.lines.map { |l| Oj.load(l) }
    end

    # Builds an ndjson string
    #
    # @param array [Array<Hash>]
    # @return [String]
    def self.to_ndjson(array)
      array.map(&:to_json).join("\n")
    end

    # Parses, yields then unparses a hash
    #
    # @param [String] json
    # @return [String]
    def self.modify_json(json, default: {})
      parsed = json.nil? ? default : Oj.load(json)
      yield(parsed)
      JSON.unparse(parsed) # TODO: why unparse?
    end

    def self.modify_json_key(hash, key, &)
      hash[key] = modify_json(hash[key], &)
    end

  end
end