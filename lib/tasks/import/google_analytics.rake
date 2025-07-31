require_relative "../../../app/lib/local_links_manager/import/analytics_importer"

namespace :import do
  desc "Imports analytics so that links can be prioritised by usage"
  task google_analytics: :environment do
    LocalLinksManager::DistributedLock.new("analytics-import").lock(
      lock_obtained: lambda {
        begin
          LocalLinksManager::Import::AnalyticsImporter.new.import_records
        rescue StandardError => e
          raise e
        end
      },
      lock_not_obtained: lambda {
      },
    )
  end
end
