FactoryBot.define do
  factory :user do
    name { "New User" }
    email { "user@email.com" }
    organisation_slug { "test-department" }
    permissions { %w[signin] }
  end
end
