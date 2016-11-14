FactoryGirl.define do
  factory :service do
    sequence(:lgsl_code) { |n| n }
    sequence(:label) { |n| "Service Label #{n}" }
    slug { label.parameterize }
    enabled true

    trait :all_tiers do
      tiers { [Tier.unitary, Tier.district, Tier.county] }
    end

    trait :district do
      tiers { [Tier.unitary, Tier.district] }
    end

    trait :county do
      tiers { [Tier.unitary, Tier.county] }
    end
  end

  factory :disabled_service, parent: :service do
    enabled false
  end
end
