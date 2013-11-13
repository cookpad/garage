require "link_header"

module RestApiSpecHelper
  extend ActiveSupport::Concern

  def link_for(rel)
    value = response.header["Link"]
    parsed = LinkHeader.parse(value)
    link = parsed.find_link(["rel", rel])
    link && Rack::Utils.parse_query(URI.parse(link.href).query).symbolize_keys
  end

  included do
    let(:link) do
      LinkHeader.parse(response.header["Link"])
    end

    let(:params) do
      {}
    end

    let(:header) do
      { "Accept" => "application/json" }
    end

    let(:env) do
      header.inject({}) do |table, (key, value)|
        table.merge("HTTP_#{key.upcase.gsub(?-, ?_)}" => value.to_s)
      end
    end

    let(:method) do
      example.full_description[/ (GET|POST|PUT|DELETE) /, 1].downcase
    end

    let(:path) do
      example.full_description[/ (?:GET|POST|PUT|DELETE) (.+?)(?: |$)/, 1].gsub(/:([^\s\/]+)/) { send($1) }
    end

    subject do
      body = params.presence
      body = params.to_json if body && env["CONTENT_TYPE"].try(:include?, "application/json")
      send(method, path, body, env)
    end
  end
end
