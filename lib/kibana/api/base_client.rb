# frozen_string_literal: true

module Kibana
  module API
    class BaseClient

      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      # delegate
      def request(**args, &)
        client.request(**args, &)
      end

      def symbolize_keys(object)
        object.transform_keys(&:to_sym)
      end

    end
  end
end