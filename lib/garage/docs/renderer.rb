module Garage
  module Docs
    class Renderer < ::Redcarpet::Render::HTML
      include ConsoleLinkBuilding
      include AnchorBuilding

      def header(text, header_level)
        if header_level == 2
          id = to_anchor(text)
          %!<a href="##{id}"><h#{header_level} id="#{id}">#{text} #{build_console_link(text)}</h#{header_level}></a>!
        else
          %!<h#{header_level}>#{text}</h#{header_level}>!
        end
      end
    end
  end
end
