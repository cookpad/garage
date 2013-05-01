module Platform2
  module ControllerHelper
    extend ActiveSupport::Concern
    included do
      use Rack::AcceptDefault
      include ::Doorkeeper::Helpers::Filter
      doorkeeper_for :all

      # TODO current_user

      rescue_from CanCan::AccessDenied do |exception|
        render :json => { :error => exception.message }, :status => :forbidden
      end

      before_filter HypermediaResponder

      respond_to :json # , :msgpack
      self.responder = Platform2::AppResponder

=begin
      before_filter Platform2::BackdoorKeeper
      def doorkeeper_token
        @token ||= Platform2::BackdoorKeeper.get_token(request.env) || super
      end
=end

    end

    def authorized_application
      doorkeeper_token.application if doorkeeper_token
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

    # for cancan
    def current_ability
      @current_ability ||= get_current_ability
    end

    def get_current_ability
      Platform2::Ability.new(current_resource_owner, doorkeeper_token).tap do |ability|
        Platform2.configuration.apply_ability(ability)
      end
    end

    def resource_owner_id
      doorkeeper_token.resource_owner_id if doorkeeper_token
    end

    def require_authentication
      head 401 unless current_resource_owner
    end

    attr_accessor :representation, :field_selector

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
