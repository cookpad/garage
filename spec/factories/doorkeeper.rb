FactoryGirl.define do
  factory :access_grant, :class => Doorkeeper::AccessGrant do
    sequence(:resource_owner_id) { |n| n }
    application
    redirect_uri "https://example.com/callback"
    expires_in 100
    scopes "public write"
  end
end

FactoryGirl.define do
  factory :access_token, :class => Doorkeeper::AccessToken do
    sequence(:resource_owner_id) { |n| n }
    application
    expires_in 2.hours
  end
end

FactoryGirl.define do
  factory :application, :class => Doorkeeper::Application do
    sequence(:name){ |n| "Application #{n}" }
    redirect_uri "https://example.com/callback"
  end
end

FactoryGirl.define do
  factory :privileged_application, :parent => :application do
    sequence(:name) { |n| "Application #{n} (privileged)" }
  end
end
