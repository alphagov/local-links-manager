RSpec.describe "Import service interactions and dependencies" do
  describe "import:service_interactions:import_all" do
    before do
      Rake.application.invoke_task("import:service_interactions:import_all")
    end

    context "when it calls the import_services rake task" do
      it "calls #import_records using the ServicesImporter" do
        importer = instance_double(LocalLinksManager::Import::ServicesImporter)
        allow(LocalLinksManager::Import::ServicesImporter).to receive(:new).and_return(importer)

        expect(importer).to receive(:import_records)

        Rake::Task["import:service_interactions:import_services"].invoke
      end
    end

    context "when it calls the import_interactions rake task" do
      it "calls #import_records using the InteractionsImporter" do
        importer = instance_double(LocalLinksManager::Import::InteractionsImporter)
        allow(LocalLinksManager::Import::InteractionsImporter).to receive(:new).and_return(importer)

        expect(importer).to receive(:import_records)

        Rake::Task["import:service_interactions:import_interactions"].invoke
      end
    end

    context "when it calls the import_service_interactions rake task" do
      it "calls #import_records using the ServiceInteractionsImporter" do
        importer = instance_double(LocalLinksManager::Import::ServiceInteractionsImporter)
        allow(LocalLinksManager::Import::ServiceInteractionsImporter).to receive(:new).and_return(importer)

        expect(importer).to receive(:import_records)

        Rake::Task["import:service_interactions:import_service_interactions"].invoke
      end
    end

    context "when it calls the add_service_tiers rake task" do
      it "calls #import_tiers using the ServicesTierImporter" do
        importer = instance_double(LocalLinksManager::Import::ServicesTierImporter)
        allow(LocalLinksManager::Import::ServicesTierImporter).to receive(:new).and_return(importer)

        expect(importer).to receive(:import_tiers)

        Rake::Task["import:service_interactions:add_service_tiers"].invoke
      end
    end

    context "when it calls the enable_services rake task" do
      it "calls #enable using the EnabledServiceChecker" do
        importer = instance_double(LocalLinksManager::Import::EnabledServiceChecker)
        allow(LocalLinksManager::Import::EnabledServiceChecker).to receive(:new).and_return(importer)

        expect(importer).to receive(:enable_services)

        Rake::Task["import:service_interactions:enable_services"].invoke
      end
    end

    context "when it calls the import_from_publishingapi rake task" do
      it "calls #import_data using the EnabledServiceChecker" do
        importer = instance_double(LocalLinksManager::Import::PublishingApiImporter)
        allow(LocalLinksManager::Import::PublishingApiImporter).to receive(:new).and_return(importer)

        expect(importer).to receive(:import_data)

        Rake::Task["import:service_interactions:import_from_publishingapi"].invoke
      end
    end
  end
end
