module Garage
  module Docs
    class Renderer < ::Redcarpet::Render::HTML
      include AnchorBuilding

      def header(text, header_level)
        console_link =
          if text.match(/^(POST|GET|PUT|DELETE)\s+(\/.*)$/)
            query = Rack::Utils.build_query(method: $1, location: $2)
            "<a href='console?#{query}'><small>(console)</small></a>"
          else
            ''
          end

        if header_level == 2
          id = to_anchor(text)
          %!<a href="##{id}"><h#{header_level} id="#{id}">#{text} #{console_link}</h#{header_level}></a>!
        else
          %!<h#{header_level}>#{text}</h#{header_level}>!
        end
      end
    end
  end
end
