require 'redcarpet'

module Garage
  module Docs
    class TocRenderer < ::Redcarpet::Render::HTML_TOC
      def header(text, header_level)
        return if header_level > 2

        console_link =
          if text.match(/^(POST|GET|PUT|DELETE)\s+(\/.*)$/)
            query = Rack::Utils.build_query(method: $1, location: $2)
            %'<a href="console?#{query}"><small>(console)</small></a>'
          else
            ''
          end

        %'<li><a href="##{header_anchor(text)}">#{text}</a> #{console_link}</li>'
      end

      def header_anchor(text)
        text.gsub(/ +/, '-').gsub(/<\/?[^>]*>/, '').downcase
      end
    end
  end
end
