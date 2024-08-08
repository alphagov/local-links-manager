class LinksTablePresenter
  def initialize(links, view_context, remove_council: false, remove_service: false)
    @links = links
    @view_context = view_context
    @remove_council = remove_council
    @remove_service = remove_service
  end

  def rows
    table_rows = @links.map do |link|
      si = link.service_interaction
      title = si.govuk_title || link.service.label
      pres = LinkPresenter.new(link)
      [
        { text: link.analytics.to_i, format: "numeric" },
        { text: "<span class=\"app-service-label\">#{title}</span>".html_safe },
        { text: "<span class=\"app-interaction-label\">#{link.interaction.label}</span>".html_safe },
        { text: link.local_authority.name },
        { text: "<span class=\"govuk-tag govuk-tag--#{pres.status_tag_colour}\">#{pres.status_description}</span>".html_safe },
        { text: @view_context.link_to("Edit <span class=\"govuk-visually-hidden\">#{link.local_authority.name} - #{si.service.label} - #{si.interaction.label}</span>".html_safe, @view_context.edit_link_path(link.local_authority, link.service, link.interaction), class: "govuk-link") },
      ]
    end

    table_rows.each { |tr| tr.delete_at(3) } if @remove_council
    table_rows.each { |tr| tr.delete_at(1) } if @remove_service

    table_rows
  end

  def headers
    table_headers = [
      {
        text: "Visits this week",
        format: "numeric",
      },
      {
        text: "Service",
      },
      {
        text: "Interaction",
      },
      {
        text: "Council",
      },
      {
        text: "Status",
      },
      {
        text: "<span class=\"govuk-visually-hidden\">Edit</span>".html_safe,
      },
    ]

    table_headers.delete_at(3) if @remove_council
    table_headers.delete_at(1) if @remove_service

    table_headers
  end
end
