require "gds_api/test_helpers/publishing_api"

describe LocalLinksManager::Import::PublishingApiImporter do
  include GdsApi::TestHelpers::PublishingApi

  describe "import of slugs and titles from Publishing API" do
    context "when Publishing API returns Local Transactions" do
      let(:local_transaction) do
        {
          "base_path" => "/ring-disposal-services",
          "description" => "Contact the council of Elrond to discuss disposing of powerful magic rings",
          "details" => {
            "lgsl_code" => 111,
            "lgil_code" => 8,
          },
          "document_type" => "local_transaction",
          "title" => "Dispose of The One Ring",
        }
      end

      let(:service0) { create(:service, lgsl_code: 111, label: "Jewellery destruction") }
      let(:service1) { create(:service) }

      let(:interaction0) { create(:interaction, lgil_code: 8, label: "Find out about") }
      let(:interaction1) { create(:interaction) }

      before do
        stub_publishing_api_has_content([local_transaction], "document_type" => "local_transaction", "per_page" => 150)
        create(:service_interaction, service: service0, interaction: interaction0)
      end

      it "reports a successful import" do
        expect(described_class.new.import_data).to be_successful
      end

      it "imports the local transaction slug and title and enables the service interaction" do
        described_class.new.import_data

        service_interaction = ServiceInteraction.find_by(service: service0, interaction: interaction0)
        expect(service_interaction.govuk_slug).to eq("ring-disposal-services")
        expect(service_interaction.govuk_title).to eq("Dispose of The One Ring")
        expect(service_interaction.live).to be true
      end

      it "warns of live service interactions not in the import" do
        create(:service_interaction, service: service1, interaction: interaction1, live: true)

        response = described_class.new.import_data

        expect(response).to_not be_successful
        expect(response.errors).to include(/1 Local Transaction is no longer in the import source/)
      end

      it "does not import transaction slugs that are not part of a service interaction" do
        another_transaction = {
          "base_path" => "/ring-finder-services",
          "description" => "Contact the council of Elrond to discuss finding powerful magic rings",
          "details" => {
            "lgsl_code" => 999,
            "lgil_code" => 2,
          },
          "document_type" => "local_transaction",
          "title" => "Finder of The One Ring",
        }
        stub_publishing_api_has_content([another_transaction], "document_type" => "local_transaction", "per_page" => 150)

        described_class.new.import_data
        service_interaction = ServiceInteraction.find_by(service: service0, interaction: interaction0)

        expect(service_interaction.govuk_slug).not_to eq("ring-finder-services")
        expect(service_interaction.govuk_title).not_to eq("Finder of The One Ring")
      end
    end

    context "Unexpected data from Publishing API" do
      it "errors if LGIL or LGSL is missing" do
        duff_local_transaction = {
          "base_path" => "/not-a-pucka-thing",
          "description" => "I don't know nuffin about LGIL codes",
          "details" => {},
          "document_type" => "local_transaction",
          "title" => "#Shrug",
        }

        stub_publishing_api_has_content([duff_local_transaction], "document_type" => "local_transaction", "per_page" => 150)

        response = described_class.new.import_data

        expect(response).to_not be_successful
        expect(response.errors).to include(/Found empty LGSL/)
      end
    end
  end
end
