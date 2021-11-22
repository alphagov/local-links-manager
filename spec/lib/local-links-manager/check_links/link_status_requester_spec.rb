require "local_links_manager/check_links/link_status_requester"
require "gds_api/test_helpers/link_checker_api"

describe LocalLinksManager::CheckLinks::LinkStatusRequester do
  include GdsApi::TestHelpers::LinkCheckerApi

  subject(:link_status_requester) { described_class.new }

  context "with homepage URLs and links for enabled services" do
    let(:local_authority1) { create(:local_authority, homepage_url: "https://www.ambridge.gov.uk") }
    let(:local_authority2) { create(:local_authority, homepage_url: "https://www.midsomer.gov.uk") }
    let!(:link1) { create(:link, local_authority: local_authority1, url: "http://www.example.com/example1.html") }
    let!(:link2) { create(:link, local_authority: local_authority2, url: "http://www.example.com/example2.html") }
    let!(:missing_link) { create(:missing_link, local_authority: local_authority1) }

    it "makes batch requests to the link checker API not including missing links" do
      stub1 = stub_link_checker_api_create_batch(
        uris: [link1.url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      stub2 = stub_link_checker_api_create_batch(
        uris: [link2.url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      stub3 = stub_link_checker_api_create_batch(
        uris: [local_authority1.homepage_url, local_authority2.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      link_status_requester.call

      expect(stub1).to have_been_requested
      expect(stub2).to have_been_requested
      expect(stub3).to have_been_requested
    end
  end

  context "with homepage URLs and links for disabled Services" do
    let!(:disabled_service_link) { create(:link_for_disabled_service) }

    it "does not test links other than the local authority homepage" do
      homepage_stub = stub_link_checker_api_create_batch(
        uris: [disabled_service_link.local_authority.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      homepage_and_link_stub = stub_link_checker_api_create_batch(
        uris: [disabled_service_link.url, disabled_service_link.local_authority.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      link_status_requester.call

      expect(homepage_stub).to have_been_requested
      expect(homepage_and_link_stub).not_to have_been_requested
    end
  end

  context "links for an authority" do
    let(:local_authority1) { create(:local_authority, slug: "ambridge", homepage_url: "https://www.ambridge.gov.uk") }
    let!(:link1) { create(:link, local_authority: local_authority1, url: "http://www.example.com/example1.html") }
    let!(:missing_link) { create(:missing_link, local_authority: local_authority1) }

    it "makes a batch request to the link checker API not including missing links" do
      stub1 = stub_link_checker_api_create_batch(
        uris: [link1.url, local_authority1.homepage_url],
        webhook_uri: "http://local-links-manager.dev.gov.uk/link-check-callback",
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )

      link_status_requester.check_authority_urls "ambridge"

      expect(stub1).to have_been_requested
    end
  end
end
