FactoryGirl.define do
  factory :service_interaction do
    association :interaction
    association :service, :all_tiers
    govuk_slug "a-slug"
    govuk_title "A title"
    live true
  end
end
