require 'rails_helper'
require 'local-links-manager/import/services_tier_importer'

describe LocalLinksManager::Import::ServicesTierImporter, :csv_importer do
  let(:csv_downloader) { instance_double LocalLinksManager::Import::CsvDownloader }
  subject { described_class.new(csv_downloader) }
  describe 'import_tiers' do
    it 'imports the tiers from the csv file and updates existing services' do
      abandoned_shopping_trolleys = FactoryGirl.create(:service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys"
      )
      arson_reduction = FactoryGirl.create(:service,
        lgsl_code: 800,
        label: "Arson reduction"
      )
      yellow_lines = FactoryGirl.create(:service,
        lgsl_code: 538,
        label: "Yellow lines"
      )

      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => 'county/unitary'
        },
        {
          :lgsl_code => '800',
          'Description' => 'Arson reduction',
          :tier => 'district/unitary'
        },
        {
          :lgsl_code => '538',
          'Description' => 'Yellow lines',
          :tier => 'all'
        },
      ]
      stub_csv_rows(csv_rows)

      expect(subject.import_tiers).to be_successful

      expect(abandoned_shopping_trolleys.reload.tiers.pluck(:name)).to match_array(%w[ county unitary ])
      expect(arson_reduction.reload.tiers.pluck(:name)).to match_array(%w[ district unitary ])
      expect(yellow_lines.reload.tiers.pluck(:name)).to match_array(%w[ district unitary county ])
    end

    it 'does not create new services for rows in the csv without a matching Service instance' do
      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => 'county/unitary'
        },
      ]
      stub_csv_rows(csv_rows)

      response = subject.import_tiers
      expect(response).not_to be_successful
      expect(response.errors).to include('LGSL 1152 is missing')

      expect(Service.exists?(lgsl_code: 1152)).to be_falsey
    end

    it 'does not update tiers to be blank' do
      abandoned_shopping_trolleys = FactoryGirl.create(:service,
        :all_tiers,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys"
      )

      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => ''
        },
      ]
      stub_csv_rows(csv_rows)

      response = subject.import_tiers
      expect(response).not_to be_successful
      expect(response.errors).to include('LGSL 1152 is missing a tier')

      expect(abandoned_shopping_trolleys.reload.tiers).not_to be_blank
    end

    it 'does not halt in the face of an error on a single row' do
      abandoned_shopping_trolleys = FactoryGirl.create(:service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys"
      )
      arson_reduction = FactoryGirl.create(:service,
        lgsl_code: 800,
        label: "Arson reduction"
      )
      soil_excavation = FactoryGirl.create(:service,
        lgsl_code: 1419,
        label: "Soil excavation"
      )

      csv_rows = [
        {
          :lgsl_code => '1152',
          'Description' => 'Abandoned shopping trolleys',
          :tier => 'county/unitary'
        },
        {
          'Description' => 'No LGSL row',
          :tier => 'all'
        },
        {
          :lgsl_code => '800',
          'Description' => 'Bad tier value row',
          :tier => 'england'
        },
        {
          :lgsl_code => '538',
          'Description' => 'Missing service row',
          :tier => 'district/unitary'
        },
        {
          :lgsl_code => '1419',
          'Description' => 'Soil excavation',
          :tier => 'district/unitary'
        },
      ]
      stub_csv_rows(csv_rows)

      response = subject.import_tiers
      expect(response).not_to be_successful
      expect(response.errors.count).to eq(3)

      expect(abandoned_shopping_trolleys.reload.tiers.pluck(:name)).to match_array(%w[ county unitary ])
      expect(arson_reduction.reload.tiers).to be_blank
      expect(soil_excavation.reload.tiers.pluck(:name)).to match_array(%w[ district unitary ])
    end
  end
end
