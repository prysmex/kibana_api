# frozen_string_literal: true

require 'test_helper'

class SavedObjectTest < Minitest::Test

  include AuthTestHelper
  include SpaceTestHelper

  def test_tag_fixture
    {attributes: {color: '#15661e', description: 'asdf', name: 'hey'}, type: 'tag'}
  end

  # tests

  def test_get
    @client.saved_object.with_space(SpaceTestHelper::TEST_ID) do |api|
      assert_raises(Kibana::Transport::ApiExceptions::NotFoundError) do
        api.get(type: 'tag', id: 'test_tag')
      end
      api.create(type: 'tag', body: test_tag_fixture, id: 'test_tag')

      assert_instance_of Hash, api.get(type: 'tag', id: 'test_tag')
    end
  end

  # def test_bulk_get
  # end

  # def test_find
  # end

  # def test_find_each_page
  # end

  # def test_create
  # end

  # def test_bulk_create
  # end

  # def test_update
  # end

  # def test_delete
  # end

  # def test_delete_by_find
  # end

  # def test_export
  # end

  # def test_import
  # end

  # def test_resolve_import_errors
  # end

  # def test_exists?
  # end

  # def test_related_objects
  # end

  # def test_counts
  # end

  # def test_find_orphans
  # end

  # def test_fields_for_index_pattern
  # end

end