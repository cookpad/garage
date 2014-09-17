module AuthenticatedContext
  extend ActiveSupport::Concern

  included do
    before do
      header["Authorization"] = "Bearer #{access_token.token}"
    end

    let(:scopes) do
      "public meta"
    end

    let(:user) do
      FactoryGirl.create(:user)
    end

    let(:resource_owner_id) do
      user.id
    end

    let(:application) do
      FactoryGirl.create(:application)
    end

    let(:application_id) do
      application.id
    end

    let(:access_token) do
      FactoryGirl.create(:access_token, resource_owner_id: resource_owner_id, scopes: scopes, application: application)
    end
  end
end
