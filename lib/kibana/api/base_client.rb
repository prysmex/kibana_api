module Kibana
  module API
    class BaseClient

      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      # delegate
      def raw_request(**args, &block)
        client.raw_request(**args, &block)
      end
      
      # delegate
      def request(**args, &block)
        client.request(**args, &block)
      end

      def symbolize_keys(object)
        object.transform_keys{|k| k.to_sym}
      end
      
    end
  end
end