module LocalLinksManager
  module Export
    class ServiceLinksExporter < LocalLinksManager::Export::LinksExporter
      def links(service_id, status, not_provided_by_authority)
        Link.joins(:service).where(services: { id: service_id }, status:, not_provided_by_authority:)
          .joins(:local_authority, :interaction)
          .select(*SELECTION)
          .order("local_authorities.name", "interactions.lgil_code").all
      end
    end
  end
end
