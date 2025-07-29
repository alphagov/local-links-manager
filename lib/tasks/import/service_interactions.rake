require_relative "../../../app/lib/local_links_manager/distributed_lock"
require_relative "../../../app/lib/local_links_manager/import/services_importer"
require_relative "../../../app/lib/local_links_manager/import/interactions_importer"
require_relative "../../../app/lib/local_links_manager/import/service_interactions_importer"
require_relative "../../../app/lib/local_links_manager/import/services_tier_importer"
require_relative "../../../app/lib/local_links_manager/import/enabled_service_checker"
require_relative "../../../app/lib/local_links_manager/import/publishing_api_importer"

namespace :import do
  namespace :service_interactions do
    desc "Import ServiceInteractions and dependencies"
    task import_all: :environment do
      LocalLinksManager::DistributedLock.new("service-imports").lock(
        lock_obtained: lambda {
          begin
            Rake::Task["import:service_interactions:import_services"].invoke
            Rake::Task["import:service_interactions:import_interactions"].invoke
            Rake::Task["import:service_interactions:import_service_interactions"].invoke
            Rake::Task["import:service_interactions:add_service_tiers"].invoke
            Rake::Task["import:service_interactions:import_from_publishingapi"].invoke
            Rake::Task["import:service_interactions:enable_services"].invoke
          rescue StandardError => e
            raise e
          end
        },
        lock_not_obtained: lambda {
        },
      )
    end

    desc "Import Services from standards.esd.org.uk"
    task import_services: :environment do
      LocalLinksManager::Import::ServicesImporter.new.import_records
    end

    desc "Import Interactions from standards.esd.org.uk"
    task import_interactions: :environment do
      LocalLinksManager::Import::InteractionsImporter.new.import_records
    end

    desc "Import ServicesInteractions from standards.esd.org.uk"
    task import_service_interactions: :environment do
      LocalLinksManager::Import::ServiceInteractionsImporter.new.import_records
    end

    desc "Add tiers from local_services.csv in publisher to the list of Services imported by `import_services`"
    task add_service_tiers: :environment do
      LocalLinksManager::Import::ServicesTierImporter.new.import_tiers
    end

    desc "Enable services used on Gov.uk"
    task enable_services: :environment do
      LocalLinksManager::Import::EnabledServiceChecker.new.enable_services
    end

    desc "Import LocalTransactions from Publishing API"
    task import_from_publishingapi: :environment do
      LocalLinksManager::Import::PublishingApiImporter.new.import_data
    end
  end
end
