feature "The local authority download CSV page" do
  let!(:local_authority) { create(:district_council) }

  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: ["signin", "GDS Editor"])
    visit local_authority_path(local_authority_slug: local_authority.slug)

    service = create(:service, :all_tiers, label: "OK Service")
    service_interaction = create(:service_interaction, service:)
    create(:link, local_authority:, service_interaction:, status: :ok)

    service = create(:service, :all_tiers, label: "Broken Service")
    service_interaction = create(:service_interaction, service:)
    create(:link, local_authority:, service_interaction:, status: :broken)

    click_on "Download Links"
  end

  describe "CSV download" do
    it "downloads a CSV" do
      find("#content").click_on "Download Links"

      expect(page.response_headers["Content-Type"]).to eq("text/csv")
    end

    context "when user leaves all link status checkboxes selected (by default)" do
      it "all services are in the CSV" do
        find("#content").click_on "Download Links"

        expect(page.text).to include("OK Service")
        expect(page.text).to include("Broken Service")
      end
    end

    context "when user unchecks one of the boxes" do
      it "only checked services are in the CSV" do
        find("#content").uncheck "Ok"
        find("#content").click_on "Download Links"

        expect(page.text).not_to include("OK Service")
        expect(page.text).to include("Broken Service")
      end
    end
  end
end
