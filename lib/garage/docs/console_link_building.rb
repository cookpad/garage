module Garage
  module Docs
    module ConsoleLinkBuilding
      def build_console_link(text)
        if text.match(/^(POST|GET|PUT|DELETE)\s+(\/.*)$/)
          query = Rack::Utils.build_query(method: $1, location: $2)
          "<a href='console?#{query}'><small>(console)</small></a>"
        else
          ''
        end
      end
    end
  end
end
