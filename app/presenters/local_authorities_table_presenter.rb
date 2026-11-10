class LocalAuthoritiesTablePresenter
  def initialize(local_authorities, view_context)
    @local_authorities = local_authorities
    @view_context = view_context
  end

  def rows
    @local_authorities.map do |authority|
      la_presenter = LocalAuthorityPresenter.new(authority)

      [
        { text: authority.links.sum { |l| l.analytics.to_i }, format: "numeric" },
        { text: authority.name },
        { text: "<span class=\"govuk-tag govuk-tag--#{la_presenter.homepage_status_colour}\">#{la_presenter.homepage_status}</span>".html_safe },
        { text: authority.active? ? "Yes" : "No" },
        { text: authority.broken_link_count, format: "numeric" },
        { text: @view_context.link_to("Edit <span class=\"govuk-visually-hidden\">#{authority.name}</span>".html_safe, @view_context.local_authority_path(authority.slug), class: "govuk-link") },
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
        text: "Council Name",
      },
      {
        text: "Homepage Status",
      },
      {
        text: "Active?",
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
