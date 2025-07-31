require_relative "../../../app/lib/local_links_manager/import/missing_links"

namespace :import do
  desc "Add missing links for links that are missing"
  task missing_links: :environment do
    LocalLinksManager::Import::MissingLinks.new.add_missing_links
  end
end
