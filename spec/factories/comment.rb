FactoryBot.define do
  factory :comment do
    user
    post
    body { Forgery(:lorem_ipsum).words(20) }
  end
end
