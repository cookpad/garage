require 'rspec/expectations'
require 'rack/test'
require 'link_header'

module RequestSpecHelper
  include Rack::Test::Methods

  def capture_redirect
    yield
  rescue ActionController::RoutingError
  end

  def response_header(key)
    last_response.headers[key]
  end

  def follow_link(rel, object=nil)
    data = object || body
    get data['_links'][rel]['href']
  end

  def body
    case last_response.content_type
    when /json/
      JSON.parse last_response.body
    when /msgpack/
      MessagePack.unpack last_response.body
    else
      last_response.body
    end
  end

  def status
    last_response.status.to_i
  end

  def current_uri
    URI.parse(page.current_url)
  end

  def link_for(rel)
    link = LinkHeader.parse(response_header('Link')).find_link(["rel", rel])
    link ? Rack::Utils.parse_query(URI.parse(link.href).query).symbolize_keys : nil
  end

  def page_for(rel)
    (l = link_for(rel)) ? l[:page].to_i : nil
  end
end

RSpec.configuration.send :include, RequestSpecHelper, :type => :request
