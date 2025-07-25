FactoryBot.define do
  factory :link do
    association :local_authority
    association :service_interaction
    sequence(:url) { |n| "http://www.example.com/#{n}" }
    status { nil }
    link_last_checked { nil }
    analytics { 0 }
    title { nil }
  end

  factory :ok_link, parent: :link do
    status { "ok" }
  end

  factory :broken_link, parent: :link do
    sequence(:url) { |n| "hhhttttttppp://www.example.com/broken-#{n}" }
    status { "broken" }
    problem_summary { "Website unvailable" }
    link_errors { ["This redirects to a page not found (404)."] }
  end

  factory :caution_link, parent: :link do
    status { "caution" }
    problem_summary { "Bad redirect" }
    link_warnings { ["This redirects too many times and will open slowly."] }
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
