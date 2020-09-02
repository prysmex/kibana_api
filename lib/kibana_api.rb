require "kibana_api/version"
require "kibana_api/api_exceptions"
require "kibana_api/http_status_codes"
require "kibana_api/v7"

module KibanaAPI

  class Error < StandardError; end
  # Your code goes here...

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_key, :api_host

    def initialize
      @api_key = ''
      @api_host = ''
    end
  end
end
