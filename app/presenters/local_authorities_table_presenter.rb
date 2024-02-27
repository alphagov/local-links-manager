class LocalAuthoritiesTablePresenter
  def initialize(local_authorities, view_context)
    @local_authorities = local_authorities
    @view_context = view_context
  end

  def rows
    @local_authorities.map do |authority|
      [
        { text: @view_context.link_to(authority.name, @view_context.local_authority_path(authority.slug, filter: "broken_links"), class: "govuk-link") },
        { text: authority.active? ? "Yes" : "No" },
        { text: authority.broken_link_count, format: "numeric" },
      ]
    end
  end

  def headers
    [
      {
        text: "Council Name",
      },
      {
        text: "Active?",
      },
      {
        text: "Broken Links",
        format: "numeric",
      },
    ]
  end
end
