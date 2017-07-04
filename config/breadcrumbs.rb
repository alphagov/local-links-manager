crumb :root do
  link "Local links", root_path
end

crumb :services do |local_authority|
  link local_authority.name, local_authority_path(local_authority.slug)
  parent :root
end

crumb :service do |service|
  link service.label, service_path(service)
  parent :root
end

crumb :links do |local_authority, service, interaction|
  link interaction.label, link_path(local_authority.slug, service.slug, interaction.slug)
  parent :service, service
end
