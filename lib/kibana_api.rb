require "kibana_api/version"
require "kibana_api/api_exceptions"
require "kibana_api/http_status_codes"
require "kibana_api/v7"
require "kibana_api/configuration"

module KibanaAPI

  class Error < StandardError; end

  # Returns the current Kibana client
  # @return [Object] Kibana client
  def self.client
    KibanaAPI::V7::Client.new
  end


  # Configuration
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
