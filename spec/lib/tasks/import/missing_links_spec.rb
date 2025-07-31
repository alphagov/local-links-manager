require "rails_helper"
require "rake"

RSpec.describe "import:missing_links" do
  before do
    importer = instance_double(LocalLinksManager::Import::MissingLinks)

    allow(importer).to receive(:add_missing_links)
    allow(LocalLinksManager::Import::MissingLinks).to receive(:new).and_return(importer)
  end

  it "calls LocalLinksManager::Import::MissingLinks.add" do
    Rake::Task["import:missing_links"].invoke

    expect(LocalLinksManager::Import::MissingLinks.new).to have_received(:add_missing_links)
  end
end
