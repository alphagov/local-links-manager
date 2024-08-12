require "csv"

module LocalLinksManager
  module Export
    class LinksExporter
      SELECTION = [
        "local_authorities.name",
        :gss,
        "services.label as service_label",
        "interactions.label as interaction_label",
        "links.status as status",
        :lgsl_code,
        :lgil_code,
        :url,
        :enabled,
        :not_provided_by_authority,
      ].freeze
      COMMON_HEADINGS = [
        "Authority Name",
        "GSS",
        "Description",
        "LGSL",
        "LGIL",
        "URL",
        "Supported by GOV.UK",
        "Not Provided by Authority",
      ].freeze
      EXTRA_HEADINGS = ["Status", "New URL"].freeze

      def self.export_links
        path = Rails.root.join("public/data/links_to_services_provided_by_local_authorities.csv")

        File.open(path, "w") do |file|
          new.export(file)
        end
      end

      def export(io)
        output = CSV.generate do |csv|
          csv << COMMON_HEADINGS
          records.each do |record|
            csv << format(record)
          end
        end
        io.write(output)
      end

      def export_links(object_id, statuses, not_provided_by_authority)
        CSV.generate do |csv|
          csv << COMMON_HEADINGS + EXTRA_HEADINGS
          statuses.each do |status|
            links(object_id, status, not_provided_by_authority).each do |link|
              csv << format(link).push(link.status)
            end
          end
        end
      end

      def records
        Link.with_url.joins(:local_authority, :service, :interaction)
          .select(*SELECTION)
          .order("local_authorities.name", "services.lgsl_code", "interactions.lgil_code").all
      end

    private

      def format(record)
        [
          record.name,
          record.gss,
          description(record),
          record.lgsl_code,
          record.lgil_code,
          record.url,
          record.enabled,
          record.not_provided_by_authority,
        ]
      end

      def description(record)
        "#{record.service_label}: #{record.interaction_label}"
      end
    end
  end
end
