describe LocalLinksManager::Import::InteractionsImporter, :csv_importer do
  describe "#import_records" do
    let(:csv_downloader) { instance_double LocalLinksManager::Import::CsvDownloader }

    context "when interactions download is successful" do
      it "imports interactions" do
        csv_rows = [
          {
            lgil_code: "0",
            label: "Applications for service",
          },
          {
            lgil_code: "30",
            label: "Application for exemption",
          },
        ]

        stub_csv_rows(csv_rows)

        expect(LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records).to be_successful

        expect(Interaction.count).to eq(2)

        interaction = Interaction.find_by(lgil_code: 30)
        expect(interaction.label).to eq("Application for exemption")
        expect(interaction.slug).to eq("application-for-exemption")
      end
    end

    context "when interactions download is not successful" do
      it "logs the error on failed download" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with(/Error downloading CSV/)

        response = LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error downloading CSV/)
      end
    end

    context "when CSV data is malformed" do
      it "logs an error that it failed importing" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with(/Malformed CSV error/)

        response = LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Malformed CSV error/)
      end
    end

    context "when runtime error is raised" do
      it "logs an error that it failed importing" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(RuntimeError, "RuntimeError")

        expect(Rails.logger).to receive(:error).with(/Error RuntimeError/)

        response = LocalLinksManager::Import::InteractionsImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error RuntimeError/)
      end
    end

    context "check imported data" do
      let(:import_comparer) { LocalLinksManager::Import::ImportComparer.new }
      let(:importer) { LocalLinksManager::Import::InteractionsImporter.new(csv_downloader, import_comparer) }

      context "when there is an empty lgil_code" do
        it "raises a MissingIdentifierError error" do
          csv_rows = [
            {
              lgil_code: "",
              label: "Applications for service",
            },
          ]
          stub_csv_rows(csv_rows)

          response = importer.import_records

          expect(response.errors).to include(/MissingIdentifierError/)
        end
      end

      context "when an interaction is no longer in the CSV" do
        it "alerts Icinga that an interaction is now missing and does not delete anything" do
          create(:interaction, lgil_code: "0", label: "Applications for service")
          create(:interaction, lgil_code: "30", label: "Applications for exemption")

          csv_rows = [
            {
              lgil_code: "0",
              label: "Applications for service",
            },
          ]
          stub_csv_rows(csv_rows)

          response = importer.import_records
          expect(response).not_to be_successful
          expect(response.errors).to include("1 Interaction is no longer in the import source.\n30\n")

          expect(Interaction.count).to eq(2)
        end
      end

      context "when no interactions are missing from the CSV" do
        it "tells Icinga that everything is fine" do
          create(:interaction, lgil_code: "0", label: "Applications for service")

          csv_rows = [
            {
              lgil_code: "0",
              label: "Applications for service",
            },
          ]
          stub_csv_rows(csv_rows)

          expect(importer.import_records).to be_successful
        end
      end
    end
  end
end
