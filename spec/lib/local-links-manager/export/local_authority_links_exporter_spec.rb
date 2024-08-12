describe LocalLinksManager::Export::LocalAuthorityLinksExporter do
  def fixture_file(file)
    File.expand_path("fixtures/#{file}", File.dirname(__FILE__))
  end

  let(:exporter) { LocalLinksManager::Export::LocalAuthorityLinksExporter.new }

  describe "#export" do
    def test_url(local_authority, interaction)
      base_url = "http://www.example.com"
      "#{base_url}/#{local_authority.gss}/#{interaction.lgil_code}"
    end

    it "exports the links to CSV format with headings" do
      service = create(:service, lgsl_code: 123, label: "Service 123")
      disabled_service = create(:disabled_service, lgsl_code: 666, label: "Service 666")
      interaction0 = create(:interaction, lgil_code: 0, label: "Interaction 0")
      interaction1 = create(:interaction, lgil_code: 1, label: "Interaction 1")
      interaction2 = create(:interaction, lgil_code: 2, label: "Interaction 2")
      service_interaction0 = create(:service_interaction, service:, interaction: interaction0)
      service_interaction1 = create(:service_interaction, service:, interaction: interaction1)
      service_interaction2 = create(:service_interaction, service:, interaction: interaction2)
      disabled_service_interaction = create(:service_interaction, service: disabled_service, interaction: interaction0)

      local_authority1 = create(:local_authority, name: "London", snac: "00AB", gss: "123")
      local_authority2 = create(:local_authority, name: "Exeter", snac: "00AD", gss: "456")

      create(:link, local_authority: local_authority1, service_interaction: service_interaction0, url: test_url(local_authority1, interaction0))
      create(:link, local_authority: local_authority1, service_interaction: service_interaction1, url: test_url(local_authority1, interaction1))
      create(:link, local_authority: local_authority2, service_interaction: service_interaction0, url: test_url(local_authority2, interaction0))
      create(:link, local_authority: local_authority2, service_interaction: service_interaction1, url: test_url(local_authority2, interaction1))
      create(:link, local_authority: local_authority2, service_interaction: disabled_service_interaction, url: test_url(local_authority2, disabled_service_interaction))
      create(:missing_link, service_interaction: service_interaction2)

      csv_file = File.read(fixture_file("exported_links.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end

    it "should use empty string if we don't have a real SNAC code" do
      service = create(:service, lgsl_code: 123, label: "Service 123")
      interaction1 = create(:interaction, lgil_code: 1, label: "Interaction 1")
      service_interaction1 = create(:service_interaction, service:, interaction: interaction1)

      pretend_ni_authority = create(:local_authority, name: "Belfast", snac: "456", gss: "456")

      create(:link, local_authority: pretend_ni_authority, service_interaction: service_interaction1, url: test_url(pretend_ni_authority, interaction1))

      csv_file = File.read(fixture_file("ni_link.csv"))

      StringIO.open do |io|
        exporter.export(io)
        expect(io.string).to eq(csv_file)
      end
    end
  end

  describe "#export_links" do
    let(:headings) { (LocalLinksManager::Export::LocalAuthorityLinksExporter::COMMON_HEADINGS + LocalLinksManager::Export::LocalAuthorityLinksExporter::EXTRA_HEADINGS).join(",") }
    let(:la) { create(:local_authority) }
    let(:ok_link) { create(:ok_link, local_authority: la) }
    let(:broken_link) { create(:broken_link, local_authority: la) }
    let(:caution_link) { create(:caution_link, local_authority: la) }
    let(:missing_link) { create(:missing_link, local_authority: la) }
    let(:pending_link) { create(:pending_link, local_authority: la) }
    let(:disabled_link) { create(:link_for_disabled_service, local_authority: la) }
    let!(:not_provided_by_authority_link) { create(:not_provided_by_authority_link, local_authority: la) }
    let!(:links) do
      {
        "ok" => ok_link,
        "broken" => broken_link,
        "caution" => caution_link,
        "missing" => missing_link,
        "pending" => pending_link,
        "disabled" => disabled_link,
      }
    end

    context "when params :not_provided_by_authority is checked" do
      let(:csv) { exporter.export_links(la.id, %w[ok], true) }

      it "exports links which have a not_provided_by_authority of true" do
        expect(csv).to include(headings)
        expect(csv).to include("#{la.name},#{la.gss},#{not_provided_by_authority_link.service.label}: #{not_provided_by_authority_link.interaction.label},#{not_provided_by_authority_link.service.lgsl_code},#{not_provided_by_authority_link.interaction.lgil_code},#{not_provided_by_authority_link.url},#{not_provided_by_authority_link.service.enabled},#{not_provided_by_authority_link.not_provided_by_authority},#{not_provided_by_authority_link.status}")
      end
    end

    %w[ok broken caution missing pending].each do |status|
      context "when params :link_status_checkbox is [#{status}]" do
        let(:statuses) { [status] }
        let(:csv) { exporter.export_links(la.id, statuses, false) }

        it "exports #{status} links for enabled services for a given local authority to CSV format with headings" do
          expect(csv).to include(headings)
          links.slice(status).each_value do |link|
            expect(csv).to include("#{la.name},#{la.gss},#{link.service.label}: #{link.interaction.label},#{link.service.lgsl_code},#{link.interaction.lgil_code},#{link.url},#{link.service.enabled},#{link.not_provided_by_authority},#{link.status}")
          end
        end

        it "does not export links for disabled services" do
          expect(csv).to_not include("#{la.name},#{la.gss},#{disabled_link.service.label}: #{disabled_link.interaction.label},#{disabled_link.service.lgsl_code},#{disabled_link.interaction.lgil_code},#{disabled_link.url},#{disabled_link.service.enabled},#{disabled_link.not_provided_by_authority},#{disabled_link.status}")
        end

        (%w[ok broken caution missing pending] - [status]).each do |status_not_in_params|
          it "does not export #{status_not_in_params} links" do
            links.except(status).each_value do |link|
              expect(csv).to_not include("#{la.name},#{la.gss},#{link.service.label}: #{link.interaction.label},#{link.service.lgsl_code},#{link.interaction.lgil_code},#{link.url},#{link.service.enabled},#{link.not_provided_by_authority},#{link.status}")
            end
          end
        end
      end
    end
  end
end
