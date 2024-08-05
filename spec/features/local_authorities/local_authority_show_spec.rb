feature "The local authority show page" do
  let!(:local_authority) { create(:district_council) }

  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: ["signin", "GDS Editor"])
    visit local_authority_path(local_authority_slug: local_authority.slug)
  end

  it "has a list of breadcrumbs pointing back to the authority that lead us here" do
    within ".govuk-breadcrumbs__list" do
      expect(page).to have_link "Home", href: root_path
      expect(page).to have_link "Councils", href: local_authorities_path(filter: %w[only_active])
      expect(page).to have_text local_authority.name
    end
  end

  it "displays the metadata" do
    expect(page).to have_content local_authority.gss
    expect(page).to have_content local_authority.local_custodian_code
    expect(page).to have_content local_authority.snac
  end

  describe "editing the homepage URL" do
    it "has an edit link homepage URL" do
      expect(page).to have_link("Edit Homepage URL", href: edit_url_local_authority_path(local_authority))
    end
  end

  describe "with no local authority homepage url" do
    it "displays 'No link'" do
      local_authority.homepage_url = nil
      local_authority.save!
      visit local_authority_path(local_authority_slug: local_authority.slug)

      expect(page).to have_content("No link")
    end

    it "does not display 'Link not checked'" do
      local_authority.homepage_url = nil
      local_authority.save!
      visit local_authority_path(local_authority_slug: local_authority.slug)

      expect(page).not_to have_content("Link not checked")
    end
  end

  describe "with an inactive council" do
    it "renders the end information successfully" do
      succeeded_by = create(:county_council)
      ni_local_authority = create(:district_council, active_end_date: Time.zone.now - 1.year, active_note: "Merged", succeeded_by_local_authority: succeeded_by)
      visit local_authority_path(local_authority_slug: ni_local_authority.slug)
      expect(page.status_code).to eq(200)

      expect(page).to have_content("Current Status inactive")
      expect(page).to have_content("Date authority became inactive")
      expect(page).to have_content("Reason Merged")
      expect(page).to have_link(succeeded_by.name, href: "/local_authorities/#{succeeded_by.slug}")
    end
  end

  describe "with a to-be inactive council" do
    it "renders the end information successfully" do
      succeeded_by = create(:county_council)
      ni_local_authority = create(:district_council, active_end_date: Time.zone.now + 1.year, active_note: "Will be merged", succeeded_by_local_authority: succeeded_by)
      visit local_authority_path(local_authority_slug: ni_local_authority.slug)
      expect(page.status_code).to eq(200)

      expect(page).to have_content("Current Status active, but being retired")
      expect(page).to have_content("Date authority is due to become inactive")
      expect(page).to have_content("Reason Will be merged")
      expect(page).to have_link(succeeded_by.name, href: "/local_authorities/#{succeeded_by.slug}")
    end
  end

  describe "with services present" do
    let(:service) { create(:service, :all_tiers) }
    let(:disabled_service) { create(:disabled_service) }
    let!(:ok_link) { create_service_interaction_link(service, status: :ok) }
    let!(:disabled_link) { create_service_interaction_link(disabled_service, status: :ok) }
    let!(:broken_link) { create_service_interaction_link(service, status: :broken) }
    let!(:missing_link) { create_missing_link(service) }

    before do
      visit local_authority_path(local_authority)
    end

    let(:http_status) { 200 }

    it "displays a filter box" do
      expect(page).to have_selector(".js-gem-c-table__filter")
    end

    it "shows missing links" do
      expect(page).to have_content("Missing")
    end

    it "shows the link status as Good Link when the status is 200" do
      expect(page).to have_text "Good"
    end

    it "shows the link last checked details" do
      expect(page).to have_text "Link not checked"
    end

    it "should have a link to Edit" do
      expect(page).to have_link "Edit", href: edit_link_path(local_authority, service, ok_link.interaction)
    end

    context "editing a link" do
      it "returns you to the correct page after updating a link" do
        click_on("Edit Local Authority Name", match: :first)
        fill_in("url", with: "http://angus.example.com/link-to-change")
        click_on("Update")

        expect(page.current_path).to eq(local_authority_path(local_authority))
      end
    end

    it "shows the status of broken links" do
      expect(page).to have_text "Broken"
    end
  end

  def create_service_interaction_link(service, status:)
    service_interaction = create(:service_interaction, service:)

    create(
      :link,
      local_authority:,
      service_interaction:,
      status:,
    )
  end

  def create_missing_link(service)
    service_interaction = create(:service_interaction, service:)

    create(
      :missing_link,
      local_authority:,
      service_interaction:,
      status: "missing",
    )
  end
end
