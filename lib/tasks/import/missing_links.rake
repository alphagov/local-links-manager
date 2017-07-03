require 'local-links-manager/import/missing_links'

namespace :import do
  desc "Add missing links for links that are missing"
  task missing_links: :environment do
    LocalLinksManager::Import::MissingLinks.add
  end
end
