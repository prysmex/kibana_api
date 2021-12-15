require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'kibana'
require 'byebug'

Minitest::Reporters.use!

module AuthTestHelper

  def setup
    @client ||= Kibana::Transport::Client.new({
      api_host: ENV['KIBANA_API_HOST'],
      api_key: ENV['KIBANA_API_KEY']
    })
  end

end

module SpaceTestHelper

  TEST_ID = '__test__'.freeze
  
  def setup
    super # ensure @client is set
    @client.space.create({
      id: TEST_ID,
      name: TEST_ID
    })
  end

  def teardown
    super
    @client.space.delete(TEST_ID)
  end

end