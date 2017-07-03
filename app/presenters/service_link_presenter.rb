class ServiceLinkPresenter < SimpleDelegator
  include UrlStatusPresentation
  attr_reader :view_context, :first

  def initialize(link, view_context:)
    super(link)
    @view_context = view_context
  end

  def interaction_label
    interaction.label
  end

  def lgsl_code
    service.lgsl_code
  end

  def service_label
    service.label
  end

  def service_slug
    service.slug
  end

  def govuk_title
    service_interaction.govuk_title
  end

  def row_data
    {
      local_authority_id: local_authority.id,
      service_id: service.id,
      interaction_id: interaction.id,
      url: url
    }
  end

  def edit_path
    view_context.edit_link_path(
      local_authority,
      service,
      interaction
    )
  end

  def link_status
    url.blank? ? "Missing" : status_description
  end
end
