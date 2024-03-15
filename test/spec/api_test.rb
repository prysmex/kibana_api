# frozen_string_literal: true

require 'test_helper'

class KibanaAPITest < Minitest::Test

  def test_respond_to_client
    assert_respond_to Kibana::API, :client
    assert_respond_to Kibana::API, :client=
  end
end