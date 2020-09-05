module Kibana
  module API
    class Dashboard < SavedObject
      def initialize  
        super
        @type = "dashboard"  
      end  
    end
  end
end