class CampaignResource
  include Garage::Representer
  include Garage::Authorizable

  def self.build_permissions(perms, other, target)
    perms.permits! :read, :write
  end

  property :id
  property :current_user_id
  delegate :id, to: :@model

  link(:self) { campaign_path(@model) }

  def initialize(model, options = {})
    @model = model
    @options = options
  end

  def build_permissions(perms, other)
    perms.permits! :read, :write
  end

  def current_user_id
    @options[:current_user]&.id
  end
end
