class Service < ApplicationRecord
  validates :lgsl_code, :label, :slug, presence: true, uniqueness: true

  has_many :service_interactions
  has_many :interactions, through: :service_interactions
  has_many :service_tiers
  has_many :tiers, through: :service_tiers

  scope :for_tier, ->(tier) {
    Service
      .joins(:service_tiers)
      .where(service_tiers: { tier: tier })
  }

  scope :enabled, -> { where(enabled: true) }
end
