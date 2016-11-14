class Service < ApplicationRecord
  validates :lgsl_code, :label, :slug, presence: true, uniqueness: true
  validates :tier, inclusion: { in: %w{all county/unitary district/unitary}, allow_nil: true }

  has_many :service_interactions
  has_many :interactions, through: :service_interactions
  has_many :service_tiers
  has_many :tiers, through: :service_tiers

  scope :for_tier, ->(tier) {
    case tier
    when 'county', 'district'
      where("services.tier = 'all' OR services.tier = '#{tier}/unitary'")
    when 'unitary', 'all'
      where.not(services: { tier: nil })
    else
      raise ArgumentError, "invalid tier '#{tier}'"
    end
  }

  scope :enabled, -> { where(enabled: true) }

  def provided_by?(authority)
    case tier
    when nil
      false
    when 'all'
      true
    else
      tiers.include? authority.tier
    end
  end
end
