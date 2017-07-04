require 'csv'

module LocalLinksManager
  module Export
    class BadLinksUrlAndStatusExporter
      HEADINGS = %w(url status).freeze

      def self.local_authority_bad_homepage_url_and_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          LocalAuthority.where.not(status: "200").distinct.pluck(:homepage_url, :status).each do |la|
            csv << la
          end
        end
      end

      def self.bad_links_url_and_status_csv
        CSV.generate do |csv|
          csv << HEADINGS
          Link.enabled_links.broken_but_not_missing.distinct.pluck(:url, :status).each do |link|
            csv << link
          end
        end
      end
    end
  end
end
