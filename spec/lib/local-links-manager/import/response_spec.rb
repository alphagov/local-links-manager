RSpec.describe LocalLinksManager::Import::Response do
  let(:importer) { described_class.new }

  describe "#initialize" do
    it "initialises with an empty array" do
      expect(importer.errors).to be_empty
    end
  end

  describe "#successful?" do
    it "returns true if there are no errors" do
      expect(importer.successful?).to be(true)
    end

    it "returns false if there are errors" do
      importer.errors << "Import error"

      expect(importer.successful?).to be(false)
    end
  end

  describe "#message" do
    it "returns 'Success' if there are no errors" do
      expect(importer.message).to eq("Success")
    end

    it "returns error messages if there are errors" do
      importer.errors << "Import error"
      importer.errors << "Analytics error"

      expect(importer.message).to eq("Import error\nAnalytics error")
    end
  end
end
