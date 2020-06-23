FactoryBot.define do
  factory :post do
    user
    title { Forgery(:lorem_ipsum).words(5) }
    body { Forgery(:lorem_ipsum).words(20) }
  end
end
