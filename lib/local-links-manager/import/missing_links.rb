module LocalLinksManager
  module Import
    class MissingLinks
      def self.add
        new.add_missing_links
      end

      def add_missing_links
        ServiceInteraction.where(live: true).each do |service_interaction|
          las_with_no_link(service_interaction).each do |local_authority_id|
            Rails.logger.info "Creating link for #{local_authority_id}, #{service_interaction.govuk_slug}"
            Link.create!(local_authority_id: local_authority_id, service_interaction: service_interaction, analytics: 0)
          end
        end
      end

      def las_with_no_link(service_interaction)
        service = service_interaction.service

        local_authorities_that_should_have_a_link = service.local_authorities.pluck(:id).sort

        local_authorities_with_a_link = Link.where(
          service_interaction: service_interaction,
          local_authority_id: local_authorities_that_should_have_a_link
        ).map(&:local_authority_id)

        local_authorities_that_should_have_a_link - local_authorities_with_a_link
      end
    end
  end
end
