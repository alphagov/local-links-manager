require_relative "bad_links_url_and_status_exporter"
require_relative "../../google_analytics/analytics_export_service"

module LocalLinksManager
  module Export
    class AnalyticsExporter
      attr_reader :client

      def initialize
        @client = GoogleAnalytics::AnalyticsExportService.new
        @service = @client.build
      end

      def bad_links_data
        LocalLinksManager::Export::BadLinksUrlAndStatusExporter.bad_links_url_and_status_csv(with_ga_headings: true)
      end

      def export_bad_links
        client.export_bad_links(bad_links_data)
      rescue StandardError => e
        logger.error "The export has failed with the following error: #{e.message}"
      end
    end
  end
end
