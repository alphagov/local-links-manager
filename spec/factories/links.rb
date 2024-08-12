FactoryBot.define do
  factory :link do
    association :local_authority
    association :service_interaction
    sequence(:url) { |n| "http://www.example.com/#{n}" }
    status { nil }
    link_last_checked { nil }
    analytics { 0 }
    not_provided_by_authority { false }
  end

  factory :not_provided_by_authority_link, parent: :link do
    status { "ok" }
    not_provided_by_authority { true }
  end

  factory :ok_link, parent: :link do
    status { "ok" }
  end

  factory :broken_link, parent: :link do
    sequence(:url) { |n| "hhhttttttppp://www.example.com/broken-#{n}" }
    status { "broken" }
  end

  factory :caution_link, parent: :link do
    status { "caution" }
  end

  factory :missing_link, parent: :link do
    url { nil }
    status { "missing" }
  end

  factory :pending_link, parent: :link do
    status { "pending" }
  end

  factory :link_for_disabled_service, parent: :link do
    after(:create) do |link|
      link.service.update(enabled: false)
    end
  end
end
