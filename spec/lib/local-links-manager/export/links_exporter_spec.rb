require 'rails_helper'
require 'local-links-manager/export/links_exporter'

describe LocalLinksManager::Export::LinksExporter do
  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  let(:exporter) { LocalLinksManager::Export::LinksExporter.new }

  describe '#export_links' do
    def test_url(local_authority, interaction)
      base_url = "http://www.example.com"
      "#{base_url}/#{local_authority.gss}/#{interaction.lgil_code}"
    end

    it "exports the links to CSV format with headings" do
      service_0 = create(:service, lgsl_code: 123, label: 'Service 123')
      service_1 = create(:service, lgsl_code: 666, label: 'Service 666')
      interaction_0 = create(:interaction, lgil_code: 0, label: 'Interaction 0')
      interaction_1 = create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service_interaction_0 = create(:service_interaction, service: service_0, interaction: interaction_0)
      service_interaction_1 = create(:service_interaction, service: service_0, interaction: interaction_1)
      disabled_service_interaction = create(:service_interaction, service: service_1, interaction: interaction_0, live: false)

      local_authority_1 = create(:local_authority, name: 'London', snac: '00AB', gss: '123')
      local_authority_2 = create(:local_authority, name: 'Exeter', snac: '00AD', gss: '456')
      local_authority_3 = create(:local_authority, name: 'Piltdown', snac: '00HA', gss: '999')


      create(:link, local_authority: local_authority_1, service_interaction: service_interaction_0, url: test_url(local_authority_1, interaction_0))
      create(:link, local_authority: local_authority_1, service_interaction: service_interaction_1, url: test_url(local_authority_1, interaction_1))
      create(:link, local_authority: local_authority_2, service_interaction: service_interaction_0, url: test_url(local_authority_2, interaction_0))
      create(:link, local_authority: local_authority_2, service_interaction: service_interaction_1, url: test_url(local_authority_2, interaction_1))
      create(:link, local_authority: local_authority_2, service_interaction: disabled_service_interaction, url: test_url(local_authority_2, disabled_service_interaction))

      # should not be included in the CSV
      create(:link, local_authority: local_authority_3, service_interaction: service_interaction_0, url: nil)

      csv_file = File.read(fixture_file("exported_links.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end

    it "should use empty string if we don't have a real SNAC code" do
      service = create(:service, lgsl_code: 123, label: 'Service 123')
      interaction_1 = create(:interaction, lgil_code: 1, label: 'Interaction 1')
      service_interaction_1 = create(:service_interaction, service: service, interaction: interaction_1)

      pretend_ni_authority = create(:local_authority, name: 'Belfast', snac: '456', gss: '456')

      create(:link, local_authority: pretend_ni_authority, service_interaction: service_interaction_1, url: test_url(pretend_ni_authority, interaction_1))

      csv_file = File.read(fixture_file("ni_link.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end
  end
end
