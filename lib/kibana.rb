require "kibana/version"
require "kibana/api_exceptions"
require "kibana/http_status_codes"
require "kibana/api"
require "kibana/configuration"

module Kibana

  class Error < StandardError; end

  # Returns the current Kibana client
  # @return [Object] Kibana client
  def self.client
    Kibana::API::Client.new
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
