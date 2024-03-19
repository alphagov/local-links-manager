namespace :once_off do
  desc "Creates service, service tier, service interaction and links for generic antisocial behaviour service"
  task antisocial_behaviour_service: :environment do
    abort("Service already exists") if Service.where(slug: "antisocial-behaviour-general").any?

    service = Service.create!(
      lgsl_code: 10_001,
      label: "Antisocial Behaviour - General",
      slug: "antisocial-behaviour-general",
      enabled: true,
      unofficial: true,
    )

    ServiceTier.create!(service:, tier_id: 1) # County
    ServiceTier.create!(service:, tier_id: 3) # Unitary

    interaction = Interaction.where(slug: "reporting").first
    service_interaction = ServiceInteraction.create!(service:, interaction:)

    LocalAuthority.active.where(tier_id: [1, 3]).find_each do |local_authority|
      Link.create!(local_authority:, service_interaction:)
    end
  end
end
