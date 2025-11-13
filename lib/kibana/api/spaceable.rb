# frozen_string_literal: true

module Kibana
  module API
    module Spaceable

      DEFAULT_SPACE = 'default'

      attr_reader :space_id

      def initialize(*, space_id: DEFAULT_SPACE, **)
        @space_id = space_id
        super(*, **)
      end

      # temporarily set the space context
      def with_space(space_id)
        prev_space = @space_id
        @space_id = space_id
        yield(self)
      ensure
        @space_id = prev_space
      end

      # iterate all spaces and set context
      def each_space(&)
        return_value = {}
        client.space.get_all.each do |space|
          id = space['id']
          return_value[id] = with_space(id, &)
        end
        return_value
      end

      private

      def current_space_api_namespace
        api_namespace_for_space(@space_id)
      end

      def api_namespace_for_space(space_id)
        if space_id.nil? || space_id.to_s == DEFAULT_SPACE
          'api'
        else
          "s/#{space_id}/api"
        end
      end

    end
  end
end