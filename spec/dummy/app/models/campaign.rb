class Campaign < ActiveRecord::Base
  def to_resource(options = {})
    CampaignResource.new(self, options)
  end
end
