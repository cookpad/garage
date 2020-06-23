FactoryBot.define do
  factory :user do
    name { Forgery(:name).full_name }
    email { Forgery(:internet).email_address }
  end
end
