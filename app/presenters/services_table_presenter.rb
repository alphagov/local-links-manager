class ServicesTablePresenter
  def initialize(services, view_context)
    @services = services
    @view_context = view_context
  end

  def rows
    @services.map do |service|
      govuk_pages = ServiceInteraction.where(service:).map(&:govuk_title)

      [
        { text: service.links.sum { |l| l.analytics.to_i }, format: "numeric" },
        { text: service.label },
        { text: govuk_pages.compact.any? ? govuk_pages.compact.join("<br />").html_safe : "Not used on GOV.UK" },
        { text: service.lgsl_code },
        { text: service.broken_link_count, format: "numeric" },
        { text: @view_context.link_to("Edit <span class=\"govuk-visually-hidden\">#{service.label}</span>".html_safe, @view_context.service_path(service), class: "govuk-link") },
      ]
    end
  end

  def headers
    [
      {
        text: "Visits this week",
        format: "numeric",
      },
      {
        text: "Service Name",
      },
      {
        text: "Page title(s) on GOV.UK",
      },
      {
        text: "LGSL Code",
      },
      {
        text: "Broken Links",
        format: "numeric",
      },
      {
        text: "<span class=\"govuk-visually-hidden\">Edit</span>".html_safe,
      },
    ]
  end
end
