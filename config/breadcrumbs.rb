crumb :local_authorities do
  link "Local Authorities", local_authorities_path
end

crumb :services do |local_authority|
  link local_authority.name, local_authority_services_path(local_authority.slug)
  parent :local_authorities
end

crumb :interactions do |local_authority, service|
  link service.label, local_authority_service_interactions_path(local_authority.slug, service.slug)
  parent :services, local_authority
end

crumb :links do |local_authority, service, interaction|
  link interaction.label, local_authority_service_interaction_links_path(local_authority.slug, service.slug, interaction.slug)
  parent :interactions, local_authority, service
end

crumb :local_links_manager do
  link 'Local links', v2_root_path
end
