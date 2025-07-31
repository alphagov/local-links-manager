describe LocalLinksManager::Import::AnalyticsImporter do
  describe "importing GA data about local authority clicks" do
    let(:ga_data) do
      [
        {
          base_path: "/living-statue-permit/sandford",
          local_link: "https://sandford-council.gov.uk/no-for-the-greater-good",
          clicks: 5,
        },
        {
          base_path: "/living-statue-permit/royston-vasey",
          local_link: "https://rv-council.gov.uk/no-for-the-greater-good",
          clicks: 4,
        },
        {
          base_path: "/trouble-at-mill",
          local_link: "https://something-unexpected.com",
          clicks: 23,
        },
      ]
    end

    let(:service_interaction) { create :service_interaction, govuk_slug: "living-statue-permit" }
    let(:sandford) { create :local_authority, slug: "sandford" }
    let(:hogsmeade) { create :local_authority, slug: "hogsmeade" }

    before do
      @sandford_link = create :link, service_interaction:, local_authority: sandford
    end

    it "imports successfully even with non-applicable data" do
      response = described_class.new(ga_data).import_records

      expect(response).to be_successful
    end

    it "imports clicks for matching councils and govuk_slugs" do
      described_class.new(ga_data).import_records

      link_with_analytics = Link.lookup_by_base_path("/living-statue-permit/sandford")
      expect(link_with_analytics.analytics).to be 5
    end

    it "resets the count for links that are not in the data set" do
      @hogsmeade_link = create :link, service_interaction:, local_authority: hogsmeade, analytics: 25

      described_class.new(ga_data).import_records

      link_with_analytics = Link.lookup_by_base_path("/living-statue-permit/hogsmeade")
      expect(link_with_analytics.analytics).to be 0
    end

    it "does not reset the count for links that are not in the data set if the import was not successful" do
      importer = described_class.new(ga_data)
      summariser = LocalLinksManager::Import::Summariser.new(importer.import_name, importer.import_source_name)
      response = importer.import_records
      response.errors << "Import error"

      importer.all_items_imported(response, summariser)

      expect(importer).not_to receive(:reset_count_on_links_not_in_analytics)
    end

    it "raises a standard error if it could not reset all old analytics counts" do
      importer = described_class.new(ga_data)
      summariser = LocalLinksManager::Import::Summariser.new(importer.import_name, importer.import_source_name)
      response = importer.import_records

      allow(importer).to receive(:reset_count_on_links_not_in_analytics).and_raise("Import error")

      importer.all_items_imported(response, summariser)

      expect(response.errors).to include(/Could not reset all old analytics counts due to: Import error/)
    end
  end
end
