class LocalAuthority < ApplicationRecord
  validates :gss, :snac, :slug, uniqueness: true
  validates :gss, :name, :snac, :slug, presence: true
  validates :tier_id, presence: true, inclusion:
    {
      in: [Tier.unitary, Tier.district, Tier.county],
      message: "%{value} is not a valid tier"
    }

  has_many :links
  belongs_to :parent_local_authority, foreign_key: :parent_local_authority_id, class_name: "LocalAuthority"
  has_many :service_tiers, foreign_key: :tier_id, primary_key: :tier_id
  has_many :services, through: :service_tiers

  def tier
    Tier.as_string(tier_id)
  end

  # returns the Links for this authority,
  # for the enabled Services that this authority provides.
  def provided_service_links
    links.joins(:service_interaction).where(service_interactions: { live: true })
  end

  def update_broken_link_count
    update_attribute(
      :broken_link_count,
      provided_service_links.broken_and_missing.count
    )
  end

  def to_param
    self.slug
  end
end
