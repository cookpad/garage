class PingsController < ApplicationController
  include Garage::RestfulActions
  include Garage::NoAuthentication

  def require_resource
    @resource = Ping.new
  end

  class Ping
    include Garage::Representer

    property :message
    attr_reader :message

    def initialize
      @message = "Pong"
    end
  end
end
