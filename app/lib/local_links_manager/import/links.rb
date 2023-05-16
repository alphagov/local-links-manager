require "csv"
require_relative "errors"

module LocalLinksManager
  module Import
    class Links
      attr_accessor :errors, :total_rows

      def initialize(local_authority)
        @local_authority = local_authority
        @errors = []
        @total_rows = 0
      end

      def import_links(csv_string)
        updated = 0
        index = 1 # start at 1 to account for headers
        CSV.parse(csv_string, headers: true) do |row|
          @total_rows += 1
          index += 1
          new_url = row["New URL"]
          next if new_url.blank?

          service = Service.find_by(lgsl_code: row["LGSL"])
          interaction = Interaction.find_by(lgil_code: row["LGIL"])

          next unless service && interaction

          slugs = {
            local_authority_slug: local_authority.slug,
            service_slug: service.slug,
            interaction_slug: interaction.slug,
          }
          link = Link.retrieve_or_build(slugs)

          begin
            link.update!(url: new_url)
            updated += 1
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.warn("#{e.message} (#{slugs.merge(link_id: link.id)})")
            errors << "Line #{index}: invalid URL '#{new_url}'"
          end
        end

        updated
      end

    private

      attr_reader :local_authority
    end
  end
end
