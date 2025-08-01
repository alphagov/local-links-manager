describe LocalLinksManager::Import::ServicesTierImporter, :csv_importer do
  let(:csv_downloader) { instance_double LocalLinksManager::Import::CsvDownloader }
  subject { described_class.new(csv_downloader) }
  describe "import_tiers" do
    it "imports the tiers from the csv file and updates existing services" do
      abandoned_shopping_trolleys = create(
        :service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys",
      )
      arson_reduction = create(
        :service,
        lgsl_code: 800,
        label: "Arson reduction",
      )
      yellow_lines = create(
        :service,
        lgsl_code: 538,
        label: "Yellow lines",
      )

      csv_rows = [
        {
          :lgsl_code => "1152",
          "Description" => "Abandoned shopping trolleys",
          :tier => "county/unitary",
        },
        {
          :lgsl_code => "800",
          "Description" => "Arson reduction",
          :tier => "district/unitary",
        },
        {
          :lgsl_code => "538",
          "Description" => "Yellow lines",
          :tier => "all",
        },
      ]
      stub_csv_rows(csv_rows)

      expect(subject.import_tiers).to be_successful
      expect(abandoned_shopping_trolleys.reload.tiers).to match_array(%w[county unitary])
      expect(arson_reduction.reload.tiers).to match_array(%w[district unitary])
      expect(yellow_lines.reload.tiers).to match_array(%w[district unitary county])
    end

    it "does not create new services for rows in the csv without a matching Service instance" do
      csv_rows = [
        {
          :lgsl_code => "1152",
          "Description" => "Abandoned shopping trolleys",
          :tier => "county/unitary",
        },
      ]
      stub_csv_rows(csv_rows)

      response = subject.import_tiers
      expect(response).not_to be_successful
      expect(response.errors).to include("LGSL 1152 is missing")

      expect(Service.exists?(lgsl_code: 1152)).to be_falsey
    end

    it "does not update tiers to be blank" do
      abandoned_shopping_trolleys = create(
        :service,
        :all_tiers,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys",
      )

      csv_rows = [
        {
          :lgsl_code => "1152",
          "Description" => "Abandoned shopping trolleys",
          :tier => "",
        },
      ]
      stub_csv_rows(csv_rows)

      response = subject.import_tiers
      expect(response).not_to be_successful
      expect(response.errors).to include("LGSL 1152 is missing a tier")

      expect(abandoned_shopping_trolleys.reload.tiers).not_to be_empty
    end

    it "does not halt in the face of an error on a single row" do
      abandoned_shopping_trolleys = create(
        :service,
        lgsl_code: 1152,
        label: "Abandoned shopping trolleys",
      )
      arson_reduction = create(
        :service,
        lgsl_code: 800,
        label: "Arson reduction",
      )
      soil_excavation = create(
        :service,
        lgsl_code: 1419,
        label: "Soil excavation",
      )

      csv_rows = [
        {
          :lgsl_code => "1152",
          "Description" => "Abandoned shopping trolleys",
          :tier => "county/unitary",
        },
        {
          "Description" => "No LGSL row",
          :tier => "all",
        },
        {
          :lgsl_code => "800",
          "Description" => "Bad tier value row",
          :tier => "england",
        },
        {
          :lgsl_code => "538",
          "Description" => "Missing service row",
          :tier => "district/unitary",
        },
        {
          :lgsl_code => "1419",
          "Description" => "Soil excavation",
          :tier => "district/unitary",
        },
      ]
      stub_csv_rows(csv_rows)

      response = subject.import_tiers
      expect(response).not_to be_successful
      expect(response.errors.count).to eq(3)

      expect(abandoned_shopping_trolleys.reload.tiers).to match_array(%w[county unitary])
      expect(arson_reduction.reload.tiers).to be_blank
      expect(soil_excavation.reload.tiers).to match_array(%w[district unitary])
    end

    it "does not import duplicate service tiers" do
      dead_animal_removal = create(
        :service,
        :county_unitary,
        lgsl_code: 576,
        label: "Dead animal removal",
      )

      csv_rows = [
        {
          :lgsl_code => "576",
          "Description" => "Dead animal removal",
          :tier => "county/unitary",
        },
      ]

      stub_csv_rows(csv_rows)

      expect { subject.import_tiers }.not_to(change { ServiceTier.where(service: dead_animal_removal.id).count })
    end

    it "updates a service's tiers to 'district' and 'unitary' when its tier changes to 'district/unitary'" do
      dead_animal_removal = create(
        :service,
        :county_unitary,
        lgsl_code: 576,
        label: "Dead animal removal",
      )

      csv_rows = [
        {
          :lgsl_code => "576",
          "Description" => "Dead animal removal",
          :tier => "district/unitary",
        },
      ]

      stub_csv_rows(csv_rows)
      subject.import_tiers
      expect(dead_animal_removal.reload.tiers).to match_array(%w[district unitary])
    end

    it "updates a service's tiers to 'county' and 'unitary' when its tier changes to 'county/unitary'" do
      dead_animal_removal = create(
        :service,
        :district_unitary,
        lgsl_code: 576,
        label: "Dead animal removal",
      )

      csv_rows = [
        {
          :lgsl_code => "576",
          "Description" => "Dead animal removal",
          :tier => "county/unitary",
        },
      ]

      stub_csv_rows(csv_rows)
      subject.import_tiers
      expect(dead_animal_removal.reload.tiers).to match_array(%w[county unitary])
    end

    it "updates a service's tiers to 'district', 'unitary' and 'county' when its tier changes to 'all'" do
      dead_animal_removal = create(
        :service,
        :district_unitary,
        lgsl_code: 576,
        label: "Dead animal removal",
      )

      csv_rows = [
        {
          :lgsl_code => "576",
          "Description" => "Dead animal removal",
          :tier => "all",
        },
      ]

      stub_csv_rows(csv_rows)
      subject.import_tiers
      expect(dead_animal_removal.reload.tiers).to match_array(%w[district unitary county])
    end

    it "updates a service's tiers to 'unitary' and 'district' when its tier changes from 'all' to 'district/unitary'" do
      dead_animal_removal = create(
        :service,
        :all_tiers,
        lgsl_code: 576,
        label: "Dead animal removal",
      )

      csv_rows = [
        {
          :lgsl_code => "576",
          "Description" => "Dead animal removal",
          :tier => "district/unitary",
        },
      ]

      stub_csv_rows(csv_rows)
      subject.import_tiers
      expect(dead_animal_removal.reload.tiers).to match_array(%w[district unitary])
    end

    it "deletes all service tiers for a service that is no longer required" do
      dead_animal_removal = create(:service, :all_tiers, lgsl_code: 576, label: "Dead animal removal")

      csv_rows = []

      stub_csv_rows(csv_rows)
      response = subject.import_tiers

      expect(response.errors).to include(/1 Service is not present in the import. Its service tiers have been deleted./)
      expect(dead_animal_removal.reload.tiers).to be_empty
    end

    it "deletes all service tiers for multiple services that are no longer required" do
      dead_animal_removal = create(:service, :all_tiers, lgsl_code: 576, label: "Dead animal removal")
      abandoned_shopping_trolleys = create(:service, lgsl_code: 1152, label: "Abandoned shopping trolleys")

      csv_rows = []
      stub_csv_rows(csv_rows)
      response = subject.import_tiers

      expect(response.errors).to include(/2 Services are not present in the import. Their service tiers have been deleted./)
      expect(dead_animal_removal.reload.tiers).to be_empty
      expect(abandoned_shopping_trolleys.reload.tiers).to be_empty
    end
  end
end
