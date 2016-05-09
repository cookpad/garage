class Campaign < ActiveRecord::Base
  def to_resource
    CampaignResource.new(self)
  end
end
