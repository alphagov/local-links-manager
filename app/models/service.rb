class Service < ApplicationRecord
  validates :lgsl_code, :label, :slug, presence: true, uniqueness: true

  has_many :service_interactions, dependent: :destroy
  has_many :links, through: :service_interactions
  has_many :interactions, through: :service_interactions
  has_many :service_tiers, dependent: :restrict_with_error
  has_many :local_authorities, through: :service_tiers
  has_many :local_authority_links, through: :links, source: :local_authority

  scope :enabled, -> { where(enabled: true) }

  VALID_TIERS = ["district/unitary", "county/unitary", "all"].freeze

  def tiers
    service_tiers.pluck(:tier_id).map { |t_id| Tier.as_string(t_id) }
  end

  def update_broken_link_count
    update(broken_link_count: Link.for_service(self).broken_or_missing.count)
  end

  def valid_tier?(tier)
    VALID_TIERS.include?(tier)
  end

  def delete_and_create_tiers(tier_name)
    delete_all_tiers
    ServiceTier.create_tiers(required_tiers(tier_name), self)
  end

  def delete_all_tiers
    service_tiers.destroy_all
  end

  def required_tiers(tier_name)
    case tier_name
    when "district/unitary"
      [Tier.district, Tier.unitary]
    when "county/unitary"
      [Tier.county, Tier.unitary]
    when "all"
      [Tier.district, Tier.unitary, Tier.county]
    end
  end

  def to_param
    slug
  end
end
