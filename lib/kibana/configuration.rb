module Kibana
  class Configuration
    attr_accessor :api_key, :api_host

    def initialize
      @api_key = nil
      @api_host = nil
    end
  end
end