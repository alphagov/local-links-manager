feature "The local authority upload CSV page" do
  let!(:local_authority) { create(:district_council) }
  let(:test_authority_path) { local_authority_path(local_authority_slug: local_authority.slug) }

  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: ["signin", "GDS Editor"])
    visit test_authority_path

    service = create(:service, :all_tiers, label: "OK Service")
    service_interaction = create(:service_interaction, service:)
    create(:link, local_authority:, service_interaction:, status: :ok)

    service = create(:service, :all_tiers, label: "Broken Service")
    service_interaction = create(:service_interaction, service:)
    create(:link, local_authority:, service_interaction:, status: :broken)

    click_on "Upload Links"
  end

  describe "Empty upload" do
    it "returns to the local authority page" do
      find("#content").click_on "Upload Links"

      expect(page.current_path).to eq(upload_links_form_local_authority_path(local_authority))
      expect(page.body).to include("A CSV file must be provided.")
    end
  end
end
