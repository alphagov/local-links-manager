desc "Updates Service records with titles/links to the GOV.UK finder documents "
task service_urls_from_govuk: :environment do
  content_store_api = GdsApi.content_store
  local_transaction_pages = GdsApi.search.search({ filter_format: "local_transaction", count: 200, fields: "title,link,content_id" })

  cs_local_transactions = local_transaction_pages["results"].map do |lap|
    ci = content_store_api.content_item(lap["link"])
    lgsl = ci.to_hash["details"]["lgsl_code"]
    lgil = ci.to_hash["details"]["lgil_code"]
    { lgsl_code: lgsl, lgil_code: lgil, title: lap["title"], path: lap["link"] }
  end

  puts("Local Transactions in content store that don't match ServiceInteraction info:")
  cs_local_transactions.each do |cslt|
    service = Service.where(lgsl_code: cslt[:lgsl_code]).first
    interaction = Interaction.where(lgil_code: cslt[:lgil_code]).first
    si = ServiceInteraction.where(service:, interaction:).first

    if si.nil?
      puts("#{cslt[:title]} / #{cslt[:path]} doesn't have a Service Interaction record")
    else
      puts("Title #{si.govuk_title} doesn't match #{cslt[:title]}") if si.govuk_title != cslt[:title]
      puts("Slug #{si.govuk_slug} doesn't match #{cslt[:path]}") if "/#{si.govuk_slug}" != cslt[:path]
    end
  end

  puts("Service Interactions without links in Content Store")
  ServiceInteraction.all.find_each do |si|
    matching = cs_local_transactions.select { |cslt| cslt[:lgsl_code] == si.service.lgsl_code && cslt[:lgil_code] == si.interaction.lgil_code }
    if matching.empty?
      puts("#{si.service.lgsl_code} / #{si.interaction.lgil_code} / #{si.govuk_title} / #{si.govuk_slug} doesn't have a Content Store record")
    elsif matching.count > 1
      puts("#{si.service.lgsl_code} / #{si.interaction.lgil_code} / #{si.govuk_title} / #{si.govuk_slug} matches #{matching.count} Content Store records")
    else
      cslt = matching.first
      puts("Title #{si.govuk_title} doesn't match #{cslt[:title]}") if si.govuk_title != cslt[:title]
      puts("Slug #{si.govuk_slug} doesn't match #{cslt[:path]}") if "/#{si.govuk_slug}" != cslt[:path]
    end
  end
end
