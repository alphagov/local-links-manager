require "rails_helper"

RSpec.describe "Export blank csvs" do
  describe "export:blank_csv" do
    before do
      service = create(:service, :district_unitary, lgsl_code: 1)
      create(:service_interaction, service:)

      service = create(:service, :county_unitary, lgsl_code: 2)
      create(:service_interaction, service:)

      clean_files
    end

    after { clean_files }

    it "should write a blank csv for a district" do
      args = Rake::TaskArguments.new(%i[tier_name], %w[district])
      Rake::Task["export:blank_csv"].execute(args)

      expect(File).to exist("blank_file_district.csv")
    end

    it "should write a blank csv for a county" do
      args = Rake::TaskArguments.new(%i[tier_name], %w[county])
      Rake::Task["export:blank_csv"].execute(args)

      expect(File).to exist("blank_file_county.csv")
    end

    it "should write a blank csv for a unitary body" do
      args = Rake::TaskArguments.new(%i[tier_name], %w[unitary])
      Rake::Task["export:blank_csv"].execute(args)

      expect(File).to exist("blank_file_unitary.csv")
    end

    it "should abort if invalid tier name is passed" do
      args = Rake::TaskArguments.new(%i[tier_name], "abcdefg")

      expect { Rake::Task["export:blank_csv"].execute(args) }.to raise_error(SystemExit, "Tier name must be one of: district, county, unitary")
    end
  end
end

def clean_files
  File.delete("blank_file_district.csv") if File.exist?("blank_file_district.csv")
  File.delete("blank_file_county.csv") if File.exist?("blank_file_county.csv")
  File.delete("blank_file_unitary.csv") if File.exist?("blank_file_unitary.csv")
end
