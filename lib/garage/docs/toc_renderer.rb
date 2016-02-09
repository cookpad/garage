module Garage
  module Docs
    class TocRenderer < ::Redcarpet::Render::HTML_TOC
      include ConsoleLinkBuilding
      include AnchorBuilding

      def header(text, header_level)
        return if header_level > 2

        %'<li><a href="##{to_anchor(text)}">#{text}</a> #{build_console_link(text)}</li>'
      end
    end
  end
end
