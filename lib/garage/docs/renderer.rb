require 'redcarpet'

module Garage
  module Docs
    class Renderer < ::Redcarpet::Render::HTML
      def header(text, header_level)
        console_link =
          if text.match(/^(POST|GET|PUT|DELETE)\s+(\/.*)$/)
            query = Rack::Utils.build_query(method: $1, location: $2)
            "<a href='console?#{query}'><small>(console)</small></a>"
          else
            ''
          end

        "<h#{header_level}>#{text} #{console_link}</h#{header_level}>"
      end
    end
  end
end
