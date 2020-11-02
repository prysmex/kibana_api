module Kibana
  module Utils

    def self.build_index_pattern(pattern, date_field, fields, space, api_host, options = {})

      scripted_fields = fields.select{|f| f['scripted'] || f[:scripted] }

      field_format_map = scripted_fields.inject({}) do |acum, field|
        #build based on type
        obj = case field['type']
        when 'number'
          {"id"=>"number"}
        else
          raise StandardError.new("scripted field type #{field['type']} not yet supported")
        end
        #add default metadata (don't know what this is for or if it's necessary)
        acum.merge({
          "#{field['name']}" => obj.merge({
            "params"=>{
              "parsedUrl"=>{
                "origin"=> api_host,
                "pathname"=>"/app/management/kibana/indexPatterns/create",
                "basePath"=>""
              }
            }
          })
        })
      end

      {
        type: 'index-pattern',
        attributes: {
          title: pattern,
          timeFieldName: date_field,
          fields: fields.to_json,
          fieldFormatMap: field_format_map.to_json #only applies when scripted fields are present
        },
        references: [],
        namespaces: [
          space
        ]
      }.merge(options)
    end
    
  end
end