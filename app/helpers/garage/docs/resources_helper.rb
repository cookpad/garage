require 'redcarpet'
require 'erb'

# coding: utf-8
module Garage::Docs::ResourcesHelper
  def markdown_file(file)
    search_paths = ["#{file}.#{@locale}.md", "#{file}.md"].map {|base| Rails.root + base }
    md_file = search_paths.find {|path| File.exist?(path) }
    markdown(ERB.new(IO.read(md_file)).result)
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, with_toc_data: true, fenced_code_blocks: true)
    markdown.render(text).html_safe
  end

  def doc_name(resource)
    resource.respond_to?(:doc_name) ? resource.doc_name : resource.name
  end
end
