class CampaignsController < ApiController
  include Garage::RestfulActions

  def require_resource
    @resource = Campaign.find(params[:id])
  end

  def require_resources
    @resources = Campaign.all
  end
end
