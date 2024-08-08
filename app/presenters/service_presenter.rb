class ServicePresenter < SimpleDelegator
  def summary_list(view_context)
    govuk_links = ServiceInteraction.where(service_id: id).map do |si|
      si.govuk_title ? view_context.link_to(si.govuk_title, "#{Plek.website_root}/#{si.govuk_slug}", class: "govuk-link") : nil
    end

    summary_items = [
      { field: "Local Government Service List (LGSL) Code", value: lgsl_code },
      { field: "Owning Departments", value: organisation_slugs.join(", ") },
      { field: "Page title(s) on GOV.UK", value: govuk_links.compact.any? ? govuk_links.compact.join("</br>").html_safe : "Not used on GOV.UK" },
    ]

    { items: summary_items }
  end
end
