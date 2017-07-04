require 'csv'

module LocalLinksManager
  module Export
    class LinksExporter
      HEADINGS = ["Authority Name", "SNAC", "GSS", "Description", "LGSL", "LGIL", "URL", "Supported by GOV.UK"].freeze

      def self.export_links
        path = Rails.root.join("public", "data", 'links_to_services_provided_by_local_authorities.csv')

        File.open(path, 'w') do |file|
          new.export(file)
        end
      end

      def export(io)
        output = CSV.generate do |csv|
          csv << HEADINGS
          records.each do |record|
            csv << format(record)
          end
        end
        io.write(output)
      end

      def records
        Link.existing
          .joins(:local_authority, :service_interaction, :service, :interaction)
          .select(
            "local_authorities.name",
            :snac,
            :gss,
            "services.label as service_label",
            "interactions.label as interaction_label",
            :lgsl_code,
            :lgil_code,
            :url,
            "service_interactions.live as live"
          ).order("local_authorities.name", "services.lgsl_code", "interactions.lgil_code").all
      end

    private

      def format(record)
        [
          record.name,
          snac(record),
          record.gss,
          description(record),
          record.lgsl_code,
          record.lgil_code,
          record.url,
          record.live
        ]
      end

      def description(record)
        "#{record.service_label}: #{record.interaction_label}"
      end

      def snac(record)
        record.snac unless record.snac == record.gss
      end
    end
  end
end
