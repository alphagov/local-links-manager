RSpec.describe "Import all local authorities and service interactions" do
  describe "import:all" do
    before(:each) do
      Rake::Task["import:all"].reenable
    end

    it "calls the local_authorities:import_all rake task" do
      expect(Rake::Task["import:local_authorities:import_all"]).to receive(:invoke)

      Rake::Task["import:all"].invoke
    end

    it "calls the service_interactions:import_all rake task" do
      expect(Rake::Task["import:service_interactions:import_all"]).to receive(:invoke)

      Rake::Task["import:all"].invoke
    end
  end
end
