class CampaignResource
  include Garage::Representer
  include Garage::Authorizable

  def self.build_permissions(perms, other, target)
    perms.permits! :read, :write
  end

  property :id
  delegate :id, to: :@model

  link(:self) { campaign_path(@model) }

  def initialize(model)
    @model = model
  end

  def build_permissions(perms, other)
    perms.permits! :read, :write
  end
end
