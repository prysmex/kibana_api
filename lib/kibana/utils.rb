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
    
  end
end