require_relative "../../../app/lib/local_links_manager/export/analytics_exporter"

namespace :export do
  namespace :google_analytics do
    desc "Export bad links status to Google Analytics"
    task "bad_links": :environment do
      if ENV["RUN_LINK_GA_EXPORT"].present? && ENV["RUN_LINK_GA_EXPORT"] == "true"
        LocalLinksManager::DistributedLock.new("bad-links-analytics-export").lock(
          lock_obtained: lambda {
            begin
              Rails.logger.info("Starting link exporter")

              LocalLinksManager::Export::AnalyticsExporter.export_bad_links

              Rails.logger.info("Bad links export to GA has completed")
            rescue StandardError => e
              Rails.logger.error("Error while running link exporter\n#{e}")
              raise e
            end
          },
          lock_not_obtained: lambda {
          },
        )
      end
    end
  end
end
