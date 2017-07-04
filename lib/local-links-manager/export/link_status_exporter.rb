require 'csv'

module LocalLinksManager
  module Export
    class LinkStatusExporter
      HEADINGS = %w(status count).freeze

      def self.homepage_links_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          LocalAuthority.group(:status).count.each do |key, value|
            csv << [key || "nil", value]
          end
        end
      end

      def self.links_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          Link.enabled_links.existing.group(:status).count.each do |key, value|
            csv << [key || "nil", value]
          end
        end
      end
    end
  end
end
