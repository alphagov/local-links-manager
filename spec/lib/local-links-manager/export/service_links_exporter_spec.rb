describe LocalLinksManager::Export::LocalAuthorityLinksExporter do
  def fixture_file(file)
    File.expand_path("fixtures/#{file}", File.dirname(__FILE__))
  end

  let(:exporter) { LocalLinksManager::Export::ServiceLinksExporter.new }

  describe "#export_links" do
    let(:headings) { (LocalLinksManager::Export::ServiceLinksExporter::COMMON_HEADINGS + LocalLinksManager::Export::ServiceLinksExporter::EXTRA_HEADINGS).join(",") }
    let(:service) { create(:service) }
    let(:local_authority) { create(:local_authority) }
    let(:local_authority2) { create(:local_authority) }
    let(:ok_link) { create(:ok_link, service:, local_authority:) }
    let(:broken_link) { create(:broken_link, service:, local_authority:) }
    # Adding this to local_authority2 allows us to check that all local authorities are included
    let(:caution_link) { create(:caution_link, service:, local_authority: local_authority2) }
    let(:missing_link) { create(:missing_link, service:, local_authority:) }
    let(:pending_link) { create(:pending_link, service:, local_authority:) }
    let(:disabled_link) { create(:link_for_disabled_service, service:, local_authority:) }
    let!(:not_provided_by_authority_link) { create(:not_provided_by_authority_link, service:, local_authority:) }
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
      let(:csv) { exporter.export_links(service.id, %w[ok], true) }

      it "exports links which have a not_provided_by_authority of true" do
        expect(csv).to include("#{not_provided_by_authority_link.local_authority.name},#{not_provided_by_authority_link.local_authority.gss},#{not_provided_by_authority_link.service.label}: #{not_provided_by_authority_link.interaction.label},#{not_provided_by_authority_link.service.lgsl_code},#{not_provided_by_authority_link.interaction.lgil_code},#{not_provided_by_authority_link.url},#{not_provided_by_authority_link.service.enabled},#{not_provided_by_authority_link.not_provided_by_authority},#{not_provided_by_authority_link.status}")
      end
    end

    %w[ok broken caution missing pending].each do |status|
      context "when statuses :link_status_checkbox is [#{status}]" do
        let(:statuses) { [status] }
        let(:csv) { exporter.export_links(service.id, statuses, false) }

        it "exports #{status} links for enabled services for a given local authority to CSV format with headings" do
          expect(csv).to include(headings)
          links.slice(status).each_value do |link|
            expect(csv).to include("#{link.local_authority.name},#{link.local_authority.gss},#{link.service.label}: #{link.interaction.label},#{link.service.lgsl_code},#{link.interaction.lgil_code},#{link.url},#{link.service.enabled},#{link.not_provided_by_authority},#{link.status}")
          end
        end

        it "does not export links for disabled services" do
          expect(csv).to_not include("#{local_authority.name},#{local_authority.gss},#{disabled_link.service.label}: #{disabled_link.interaction.label},#{disabled_link.service.lgsl_code},#{disabled_link.interaction.lgil_code},#{disabled_link.url},#{disabled_link.service.enabled},#{disabled_link.status}")
        end

        (%w[ok broken caution missing pending] - [status]).each do |status_not_in_params|
          it "does not export #{status_not_in_params} links" do
            links.except(status).each_value do |link|
              expect(csv).to_not include("#{link.local_authority.name},#{link.local_authority.gss},#{link.service.label}: #{link.interaction.label},#{link.service.lgsl_code},#{link.interaction.lgil_code},#{link.url},#{link.service.enabled},#{link.status}")
            end
          end
        end
      end
    end
  end
end
