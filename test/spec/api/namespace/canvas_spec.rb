require 'test_helper'

class CanvasTest < Minitest::Test

  include AuthTestHelper
  include SpaceTestHelper

  def test_find
    response = @client.canvas.with_space(SpaceTestHelper::TEST_ID) do |api|
      api.find(params: { perPage: 10, name: nil })
    end
    assert_equal true, response.key?('total')
  end

end