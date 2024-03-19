class ServicePresenter < SimpleDelegator
  def summary_list(view_context)
    govuk_links = ServiceInteraction.where(service_id: id).map do |si|
      si.govuk_title ? view_context.link_to(si.govuk_title, "#{Plek.website_root}/#{si.govuk_slug}", class: "govuk-link") : nil
    end

    summary_items = []
    summary_items <<  { field: "Local Government Service List (LGSL) Code", value: lgsl_code }
    summary_items <<  { field: "GOV.UK Pages", value: govuk_links.compact.any? ? govuk_links.compact.join("</br>").html_safe : "Not used on GOV.UK" }

    summary_items << { field: "Unofficial", value: "Not specified by <a href=\"https://standards.esd.org.uk/?uri=list%2FenglishAndWelshServices\" class=\"govuk-link\">esd.org.uk</a>".html_safe } if unofficial

    { items: summary_items }
  end
end
