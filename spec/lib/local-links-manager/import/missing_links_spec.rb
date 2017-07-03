require 'rails_helper'
require 'local-links-manager/import/missing_links'

describe LocalLinksManager::Import::MissingLinks do
  describe "#add_missing_links" do
    let!(:disabled_service_interaction) { create(:service_interaction)}
    let!(:first_live_service_interaction) { create(:service_interaction, live: true)}
    let!(:second_live_service_interaction) { create(:service_interaction, live: true)}


    let!(:council_with_no_links) { create(:local_authority)}
    let!(:council_with_a_link) { create(:local_authority)}

    it "adds a missing link for each live service interaction that a council does not have a link for" do
      described_class.new.add_missing_links

      expect(council_with_no_links.provided_service_links.count).to be(2)
    end

    it "does not add a link if the local authority already has one for that service interaction" do
      create(:link, service_interaction: first_live_service_interaction, local_authority: council_with_a_link)

      described_class.new.add_missing_links

      expect(council_with_a_link.links.where(url: nil).count).to eq(1)
      expect(council_with_a_link.links.existing.count).to eq(1)
    end

    it "does not add links for service interactions that are not live" do
      described_class.new.add_missing_links

      expect(Link.where(service_interaction: disabled_service_interaction).count).to eq(0)
    end
  end
end
