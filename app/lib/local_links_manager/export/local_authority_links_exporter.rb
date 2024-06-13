module LocalLinksManager
  module Export
    class LocalAuthorityLinksExporter < LocalLinksManager::Export::LinksExporter
      def links(local_authority_id, status, not_provided_by_authority)
        Link.enabled_links
          .where(local_authority_id:, status:, not_provided_by_authority:)
          .joins(:local_authority, :service, :interaction)
          .select(*SELECTION)
          .order("services.lgsl_code", "interactions.lgil_code").all
      end
    end
  end
end
