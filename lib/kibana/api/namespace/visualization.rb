module Kibana
  module API
    class Visualization < SavedObject
      def initialize  
        super
        @type = "visualization"  
      end  
    end
  end
end