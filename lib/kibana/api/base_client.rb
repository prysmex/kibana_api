module Kibana
  module API
    class BaseClient

      attr_reader :client

      def initialize(client)
        @client = client
      end

      # # handle respond_to?
      # def respond_to_missing?(_method, include_private = false)
      #   if _method.to_s.sub(/_raw/, '')
      #     return
      #   end
      #   super(_method, include_private)
      # end

      # # catch missing method
      # def method_missing(_method, *args, &block)
      #   if _method.to_s.sub(//)
      #     return
      #   end
      #   super(_method, *args, &block)
      # end

      private
      
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