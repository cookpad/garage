module AuthenticatedContext
  extend ActiveSupport::Concern

  included do
    before do
      header["Accept"] = "application/json"
      header["Authorization"] = "Bearer #{access_token.token}"
    end

    let(:scopes) do
      "public meta"
    end

    let(:access_token) do
      FactoryGirl.create(:access_token, scopes: scopes, resource_owner_id: resource_owner_id)
    end

    let(:user) do
      FactoryGirl.create(:user)
    end

    let(:resource_owner_id) do
      user.id
    end
  end
end
