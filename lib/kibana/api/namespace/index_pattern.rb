module Kibana
  module API
    class IndexPattern < SavedObject
      def initialize  
        super
        @type = "index-pattern"  
      end  
    end
  end
end