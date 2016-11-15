class LocalAuthority < ApplicationRecord
  after_update :reset_time_and_status, if: :homepage_url_changed?

  validates :gss, :snac, :slug, uniqueness: true
  validates :gss, :name, :snac, :tier, :slug, presence: true
  validates :homepage_url, non_blank_url: true, allow_blank: true
  validates :tier_id, presence: true

  has_many :links
  belongs_to :parent_local_authority, foreign_key: :parent_local_authority_id, class_name: "LocalAuthority"
  belongs_to :tier

  def provided_services
    Service.for_tier(self.tier).enabled
  end

  def update_broken_link_count
    update_attribute(
      :broken_link_count,
      links.have_been_checked.currently_broken.count
    )
  end

private

  def reset_time_and_status
    self.update_columns(status: nil, link_last_checked: nil)
  end
end
