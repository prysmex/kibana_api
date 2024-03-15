# frozen_string_literal: true

require 'test_helper'

class FeaturesTest < Minitest::Test

  include AuthTestHelper

  def test_features
    assert_instance_of Array, @client.features.features
  end

end