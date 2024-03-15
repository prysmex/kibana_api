# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'kibana'
require 'debug'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'

Minitest::Reporters.use!

module AuthTestHelper

  def setup
    @client ||= Kibana::Transport::Client.new( # rubocop:disable Naming/MemoizedInstanceVariableName
      api_host: ENV.fetch('KIBANA_API_HOST', nil),
      api_key: ENV.fetch('KIBANA_API_KEY', nil)
    )
  end

end

module SpaceTestHelper

  TEST_ID = '__test__'

  def setup
    super # ensure @client is set
    @client.space.create(
      id: TEST_ID,
      name: TEST_ID
    )
  end

  def teardown
    super
    @client.space.delete(TEST_ID)
  end

end