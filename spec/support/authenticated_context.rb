module AuthenticatedContext
  extend ActiveSupport::Concern

  included do
    before do
      header["Authorization"] = "Bearer dummy-access-token"
      stub_access_token_request(resource_owner_id: resource_owner_id, scope: scopes, application_id: application_id)
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

    let(:application_id) do
      SecureRandom.hex(32)
    end
  end
end
