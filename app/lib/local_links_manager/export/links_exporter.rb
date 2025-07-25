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
        :title,
        :enabled,
        :problem_summary,
        :link_errors,
        :link_warnings,
      ].freeze
      COMMON_HEADINGS = [
        "Authority Name",
        "GSS",
        "Description",
        "LGSL",
        "LGIL",
        "URL",
        "Title",
        "Supported by GOV.UK",
      ].freeze
      EXTRA_HEADINGS = ["Status", "Problem summary", "Status error", "Status warning", "New URL", "New Title"].freeze

      def export(io)
        output = CSV.generate do |csv|
          csv << COMMON_HEADINGS
          records.each do |record|
            csv << format(record)
          end
        end
        io.write(output)
      end

      def export_links(object_id, statuses)
        CSV.generate do |csv|
          csv << COMMON_HEADINGS + EXTRA_HEADINGS
          statuses.each do |status|
            links(object_id, status).each do |link|
              csv << format(link).push(link.status, link.problem_summary, link.link_errors.first, link.link_warnings.first)
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
          record.title,
          record.enabled,
        ]
      end

      def description(record)
        "#{record.service_label}: #{record.interaction_label}"
      end
    end
  end
end
