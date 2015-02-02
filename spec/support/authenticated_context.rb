module AuthenticatedContext
  extend ActiveSupport::Concern

  included do
    before do
      header["Authorization"] = "Bearer dummy-token"
      header["Resource-Owner-Id"] = resource_owner_id
      header["Application-Id"] = application_id
      header["Scope"] = scopes
      header["ExpiredAt"] = nil
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
      rand(128)
    end
  end
end
