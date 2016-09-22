class Link < ActiveRecord::Base
  before_update :set_time_and_status_on_updated_link, if: :url_changed?
  before_create :set_time_and_status_on_new_link

  belongs_to :local_authority
  belongs_to :service_interaction

  has_one :service, through: :service_interaction
  has_one :interaction, through: :service_interaction

  validates :local_authority, :service_interaction, presence: true
  validates :service_interaction_id, uniqueness: { scope: :local_authority_id }
  validates :url, presence: true, non_blank_url: true

  scope :for_service, ->(service) {
    includes(service_interaction: [:service, :interaction])
      .references(:service_interactions)
      .where(service_interactions: { service_id: service })
  }

  def self.broken
    self.where.not(status: '200')
  end

  def self.enabled_links
    self.joins(:service).where(services: { enabled: true })
  end

  def self.retrieve(params)
    self.joins(:local_authority, :service, :interaction).find_by(
      local_authorities: { slug: params[:local_authority_slug] },
      services: { slug: params[:service_slug] },
      interactions: { slug: params[:interaction_slug] }
    ) || build(params)
  end

  def self.find_by_service_and_interaction(service, interaction)
    self.joins(:service, :interaction).find_by(
      services: { id: service.id },
      interactions: { id: interaction.id }
    )
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
