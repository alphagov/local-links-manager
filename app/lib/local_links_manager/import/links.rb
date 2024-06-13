require "csv"
require_relative "errors"

module LocalLinksManager
  module Import
    class Links
      attr_accessor :errors, :total_rows

      def initialize(type:, object:)
        @type = type
        @object = object
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
          not_provided_by_authority = row["Not Provided by Authority"]
          next if new_url.blank?

          local_authority = LocalAuthority.find_by(gss: row["GSS"])
          service = Service.find_by(lgsl_code: row["LGSL"])
          interaction = Interaction.find_by(lgil_code: row["LGIL"])

          next unless local_authority && service && interaction
          next unless valid_for_this_object?(local_authority, service)

          slugs = {
            local_authority_slug: local_authority.slug,
            service_slug: service.slug,
            interaction_slug: interaction.slug,
          }
          link = Link.retrieve_or_build(slugs)

          begin
            link.update!(url: new_url)
            link.update!(not_provided_by_authority:) if not_provided_by_authority
            updated += 1
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.warn("#{e.message} (#{slugs.merge(link_id: link.id)})")
            errors << "Line #{index}: invalid URL '#{new_url}'"
          end
        end

        updated
      end

    private

      def valid_for_this_object?(local_authority, service)
        return false if type == :local_authority && local_authority.id != object.id
        return false if type == :service && service.id != object.id

        true
      end

      attr_reader :type, :object
    end
  end
end
