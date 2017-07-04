class Link < ApplicationRecord
  before_update :set_time_and_status_on_updated_link, if: :url_changed?
  before_create :set_time_and_status_on_new_link

  belongs_to :local_authority, touch: true
  belongs_to :service_interaction, touch: true

  has_one :service, through: :service_interaction
  has_one :interaction, through: :service_interaction

  validates :local_authority, :service_interaction, presence: true
  validates :service_interaction_id, uniqueness: { scope: :local_authority_id }
  validates :url, non_blank_url: true

  scope :existing, -> { where.not(url: nil) }
  scope :for_service, ->(service) {
    includes(service_interaction: [:service, :interaction])
      .references(:service_interactions)
      .where(service_interactions: { service_id: service })
  }

  HTTP_OK_STATUS_CODE = "200".freeze
  UNCHECKED_STATUS_CODE = "NULL".freeze

  OK_STATUS_CODES = [HTTP_OK_STATUS_CODE, UNCHECKED_STATUS_CODE].freeze

  scope :good_links, -> { where(status: HTTP_OK_STATUS_CODE) }
  scope :broken_and_missing, -> { where("status NOT IN (?) OR url IS NULL", OK_STATUS_CODES) }
  scope :broken_but_not_missing, -> { where("status NOT IN (?) AND url IS NOT NULL", OK_STATUS_CODES) }
  scope :currently_broken, -> { where.not(status: HTTP_OK_STATUS_CODE) }
  scope :have_been_checked, -> { where("status != ? OR url IS NULL", UNCHECKED_STATUS_CODE) }

  def self.enabled_links
    self.joins(:service_interaction).where(service_interactions: { live: true })
  end

  def self.retrieve(params)
    self.joins(:local_authority, :service, :interaction).find_by(
      local_authorities: { slug: params[:local_authority_slug] },
      services: { slug: params[:service_slug] },
      interactions: { slug: params[:interaction_slug] }
    ) || build(params)
  end

  def self.find_by_service_and_interaction(service, interaction)
    self.joins(:service, :interaction).where(
      services: { id: service.id },
      interactions: { id: interaction.id }
    ).where.not(url: nil).first
  end

  def self.find_by_base_path(base_path)
    govuk_slug, local_authority_slug = base_path[1..-1].split("/")

    self.joins(:local_authority, :service_interaction)
      .find_by(local_authorities: { slug: local_authority_slug },
       service_interactions: { govuk_slug: govuk_slug })
  end

  def self.build(params)
    Link.new(
      local_authority: LocalAuthority.find_by(slug: params[:local_authority_slug]),
      service_interaction: ServiceInteraction.find_by(
        service: Service.find_by(slug: params[:service_slug]),
        interaction: Interaction.find_by(slug: params[:interaction_slug]),
      )
    )
  end

private

  def link_with_matching_url
    existing_link_url || existing_homepage_url
  end

  def existing_link_url
    @_link ||= Link.where(url: self.url).distinct.first
  end

  def existing_homepage_url
    @_authority_link ||= LocalAuthority.where(homepage_url: self.url).first
  end

  def set_time_and_status_on_updated_link
    if link_with_matching_url
      set_status_and_last_checked_for(link_with_matching_url)
    else
      self.update_columns(status: nil, link_last_checked: nil)
    end
  end

  def set_time_and_status_on_new_link
    set_status_and_last_checked_for(link_with_matching_url) if link_with_matching_url
  end

  def set_status_and_last_checked_for(link)
    self.status = link.status
    self.link_last_checked = link.link_last_checked
  end
end
