module Kibana
  module Utils

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

    def self.build_index_pattern(pattern, date_field, fields, api_host, options = {})

      scripted_fields = fields.select{|f| f['scripted'] || f[:scripted] }

      field_format_map = scripted_fields.inject({}) do |acum, field|
        #build based on type
        obj = case field['type']
        when 'number'
          {'id'=>'number'}
        else
          raise StandardError.new("scripted field type #{field['type']} not yet supported")
        end
        #add default metadata (don't know what this is for or if it's necessary)
        acum.merge({
          :"#{field['name']}" => obj.merge({
            params: {
              parsedUrl: {
                origin:  api_host,
                pathname: '/app/management/kibana/indexPatterns/create',
                basePath: ''
              }
            }
          })
        })
      end

      options.merge({
        type: 'index-pattern',
        attributes: {
          title: pattern,
          timeFieldName: date_field,
          fields: fields.to_json,
          fieldFormatMap: field_format_map.to_json #only applies when scripted fields are present
        },
        references: []
      })
    end
    
  end
end