require 'rails_helper'
require 'local-links-manager/import/publishing_api_importer'
require 'gds_api/test_helpers/publishing_api_v2'

describe LocalLinksManager::Import::PublishingApiImporter do
  include GdsApi::TestHelpers::PublishingApiV2

  describe 'import of slugs and titles from Publishing API' do
    context 'when Publishing API returns Local Transactions' do
      let(:local_transaction) {
        {
          "base_path" => "/ring-disposal-services",
          "description" => "Contact the council of Elrond to discuss disposing of powerful magic rings",
          "details" => {
            "lgsl_code" => 111,
            "lgil_code" => 8
          },
          "document_type" => "local_transaction",
          "title" => "Dispose of The One Ring",
        }
      }

      let(:service_0) { create(:service, lgsl_code: 111, label: "Jewellery destruction") }
      let(:service_1) { create(:service, lgsl_code: 451, label: "Breeding Uruk-hai") }

      let(:interaction_0) { create(:interaction, lgil_code: 8, label: "Find out about") }
      let(:interaction_1) { create(:interaction, lgil_code: 17, label: "Report") }

      before do
        publishing_api_has_content([local_transaction], "document_type" => "local_transaction", "per_page" => 150)
        create(:service_interaction, service: service_0, interaction: interaction_0)
      end

      it 'reports a successful import' do
        expect(described_class.import).to be_successful
      end

      it 'imports the local transaction slug and title and enables the service interaction' do
        described_class.import

        service_interaction = ServiceInteraction.find_by(service: service_0, interaction: interaction_0)
        expect(service_interaction.govuk_slug).to eq('ring-disposal-services')
        expect(service_interaction.govuk_title).to eq('Dispose of The One Ring')
        expect(service_interaction.live).to be true
      end

      it "warns of live service interactions not in the import" do
        create(:service_interaction, service: service_1, interaction: interaction_1, live: true)

        response = described_class.import

        expect(response).to_not be_successful
        expect(response.errors).to include(/1 Local Transaction is no longer in the import source/)
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

        publishing_api_has_content([duff_local_transaction], "document_type" => "local_transaction", "per_page" => 150)

        response = described_class.import

        expect(response).to_not be_successful
        expect(response.errors).to include(/Found empty LGSL/)
      end
    end
  end
end
