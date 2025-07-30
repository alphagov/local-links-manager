describe LocalLinksManager::Import::ServicesImporter, :csv_importer do
  describe "#import_records" do
    let(:csv_downloader) { instance_double LocalLinksManager::Import::CsvDownloader }
    let(:import_comparer) { LocalLinksManager::Import::ImportComparer.new }

    context "when services download is successful" do
      it "imports services" do
        csv_rows = [
          {
            lgsl_code: "1614",
            label: "16 to 19 bursary fund",
          },
          {
            lgsl_code: "13",
            label: "Abandoned shopping trolleys",
          },
        ]

        stub_csv_rows(csv_rows)

        expect(LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records).to be_successful

        expect(Service.count).to eq(2)

        service = Service.find_by(lgsl_code: 1614)
        expect(service.label).to eq("16 to 19 bursary fund")
        expect(service.slug).to eq("16-to-19-bursary-fund")
      end
    end

    context "when services download is not successful" do
      it "logs the error on failed download" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Error downloading CSV")

        expect(Rails.logger).to receive(:error).with(/Error downloading CSV/)

        response = LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error downloading CSV/)
      end
    end

    context "when CSV data is malformed" do
      it "logs an error that it failed importing" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(LocalLinksManager::Import::CsvDownloader::DownloadError, "Malformed CSV error")

        expect(Rails.logger).to receive(:error).with(/Malformed CSV error/)

        response = LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Malformed CSV error/)
      end
    end

    context "when runtime error is raised" do
      it "logs an error that it failed importing" do
        allow(csv_downloader).to receive(:each_row)
          .and_raise(RuntimeError, "RuntimeError")

        expect(Rails.logger).to receive(:error).with(/Error RuntimeError/)

        response = LocalLinksManager::Import::ServicesImporter.new(csv_downloader).import_records
        expect(response).to_not be_successful
        expect(response.errors).to include(/Error RuntimeError/)
      end
    end

    context "check imported data" do
      let(:import_comparer) { LocalLinksManager::Import::ImportComparer.new }
      let(:importer) { LocalLinksManager::Import::ServicesImporter.new(csv_downloader, import_comparer) }

      context "when a service is no longer in the CSV" do
        it "returns a failure message and does not delete anything" do
          create(:service, lgsl_code: "1614", label: "16 to 19 bursary fund")
          create(:service, lgsl_code: "13", label: "Abandoned shopping trolleys")
          create(:service, lgsl_code: "427", label: "Overheated porridge")

          csv_rows = [
            {
              lgsl_code: "1614",
              label: "16 to 19 bursary fund",
            },
          ]
          stub_csv_rows(csv_rows)

          response = importer.import_records
          expect(response).not_to be_successful
          expect(response.errors).to include("2 Services are no longer in the import source.\n13\n427\n")

          expect(Service.count).to eq(3)
        end
      end

      context "when no services are missing from the CSV" do
        it "reports a successful import" do
          create(:service, lgsl_code: "1614", label: "16 to 19 bursary fund")

          csv_rows = [
            {
              lgsl_code: "1614",
              label: "16 to 19 bursary fund",
            },
          ]
          stub_csv_rows(csv_rows)

          expect(importer.import_records).to be_successful
        end
      end

      context "when a service has a blank code in the CSV" do
        it "raises a MissingIdentifierError error" do
          create(:service, lgsl_code: "1614", label: "16 to 19 bursary fund")

          csv_rows = [
            {
              lgsl_code: "",
              label: "16 to 19 bursary fund",
            },
          ]
          stub_csv_rows(csv_rows)

          response = importer.import_records

          expect(response.errors).to include(/MissingIdentifierError/)
        end
      end
    end
  end
end
