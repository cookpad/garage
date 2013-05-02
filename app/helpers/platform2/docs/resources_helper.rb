require 'redcarpet'

# coding: utf-8
module Platform2::Docs::ResourcesHelper
  def markdown_file(file)
    markdown(File.open(Rails.root + file).read)
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, with_toc_data: true, fenced_code_blocks: true)
    markdown.render(text).html_safe
  end
end
