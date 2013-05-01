module Platform2
  class ResourcesController < ApplicationController # FIXME Metal?
    use Rack::AcceptDefault

    # TODO current_user

    def handle
      # FIXME catch errors?
      res = Rails.application.routes.call(env)
      self.status = res[0]
      self.headers = res[1] # FIXME
      self.response_body = res[2]
    end

    rescue_from CanCan::AccessDenied do |exception|
      render :json => { :error => exception.message }, :status => :forbidden
    end
=begin
    before_filter Platform2::BackdoorKeeper
    def doorkeeper_token
      @token ||= Platform2::BackdoorKeeper.get_token(request.env) || super
    end
=end

    # install them the installed application
    def authorized_application
      doorkeeper_token.application if doorkeeper_token
    end

    def current_resource_owner
      @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
    end

    # Hack: returns if the current resource is the same as the requester
    def request_by?(resource)
      true # FIXME
      # resource.is_a?(User) && current_resource_owner.try(:id) == resource.id
    end

    # Public: returns if the current request includes the given OAuth scope
    def has_scope?(scope)
      doorkeeper_token && doorkeeper_token.scopes.include?(scope)
    end
=begin
    # for cancan
    def current_ability
      @current_ability ||= Platform2::Ability.new(current_resource_owner, doorkeeper_token)
    end
=end
    def resource_owner_id
      doorkeeper_token.resource_owner_id if doorkeeper_token
    end

    def require_authentication
      head 401 unless current_resource_owner
    end

    attr_accessor :representation, :field_selector
    before_filter HypermediaResponder

    def self.respond_platform
      respond_to :json # , :msgpack
      self.responder = Platform2::AppResponder
    end

  private

    # TODO move this to ::Utils

    # Private: extract date time range query from query parameters
    # Treat `from` and `to` as aliases for `gte` and `lte` respectively
    def extract_datetime_query(prefix)
      query = {}
      {:from => :gte, :to => :lte, :gt => nil, :lt => nil, :gte => nil, :lte => nil}.each do |key, as|
        k = "#{prefix}.#{key}"
        if params.has_key?(k)
          query[as || key] = fuzzy_parse(params[k]) or raise HTTPStatus::BadRequest, "Can't parse datetime #{params[k]}"
        end
      end
      query if query.size > 0
    end

    def fuzzy_parse(date)
      if date.is_a?(Numeric) || /^\d+$/ === date
        Time.zone.at(date.to_i)
      else
        Time.zone.parse(date)
      end
    rescue ArgumentError
      nil
    end
  end
end

