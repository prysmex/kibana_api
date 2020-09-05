require "kibana/version"
require "kibana/api_exceptions"
require "kibana/http_status_codes"
require "kibana/api"
require "kibana/configuration"

module Kibana

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
