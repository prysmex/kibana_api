require 'test_helper'

class RoleTest < Minitest::Test

  include AuthTestHelper

  ROLE_ID = '__test_role__'.freeze

  def create_test_role
    @client.role.put(id: ROLE_ID, body: {})
  end

  def delete_test_role
    @client.role.delete(id: ROLE_ID)
  end

  # tests

  def test_put
    create_test_role

    # updates an existing role
    @client.role.put(id: ROLE_ID, body: { metadata: { hey: 1} })
    assert_equal 1, @client.role.get_by_id(id: ROLE_ID).dig('metadata', 'hey')

    # creates a new role
    @client.role.put(id: 'wrong_id', body: {})
    refute_nil @client.role.get_by_id(id: 'wrong_id')
    @client.role.delete(id: 'wrong_id')

    delete_test_role
  end

  def test_get_by_id
    create_test_role
    refute_nil @client.role.get_by_id(id: ROLE_ID) # found
    delete_test_role

    # raises error when not found
    assert_raises(Kibana::Transport::ApiExceptions::NotFoundError) { @client.role.get_by_id(id: '789234hjk') }
  end

  def test_get_all
    assert_instance_of Array, @client.role.get_all
  end

  def test_delete
    create_test_role
    refute_nil @client.role.get_by_id(id: ROLE_ID) # found
    delete_test_role

    # not found
    assert_raises(Kibana::Transport::ApiExceptions::NotFoundError) { @client.role.get_by_id(id: ROLE_ID) }
  end

end