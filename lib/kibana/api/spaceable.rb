# frozen_string_literal: true

module Kibana
  module API
    module Spaceable

      attr_reader :space_id

      def initialize(*args)
        @space_id = 'default'
        super(*args)
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
      def each_space(&block)
        return_value = {}
        client.space.get_all.each do |space|
          id = space['id']
          return_value[id] = with_space(id, &block)
        end
        return_value
      end

      private

      def current_space_api_namespace
        api_namespace_for_space(@space_id)
      end

      def api_namespace_for_space(space_id)
        if space_id.nil? || space_id.to_s == 'default'
          'api'
        else
          "s/#{space_id}/api"
        end
      end

    end
  end
end