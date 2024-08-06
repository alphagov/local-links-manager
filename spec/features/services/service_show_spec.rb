feature "The services show page" do
  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: ["signin", "GDS Editor"])

    @service = create(:service, :all_tiers)
    service_interaction = create(:service_interaction, service: @service)
    @council_a = create(:unitary_council, name: "aaa")
    @council_z = create(:district_council, name: "zzz")
    @link1 = create(
      :link,
      local_authority: @council_a,
      service_interaction:,
      status: "ok",
      link_last_checked: "1 day ago",
    )
    @link2 = create(
      :link,
      local_authority: @council_z,
      service_interaction:,
      status: "broken",
      problem_summary: "404 error (page not found)",
      link_errors: ["Received 404 response from the server."],
    )
    visit service_path(@service)
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector(".govuk-breadcrumbs__list")
  end

  it "displays the name of the service" do
    expect(page).to have_content(@service.label)
    expect(page).to have_content(@service.lgsl_code)
  end

  it "shows each of the councils which provide this service" do
    expect(page).to have_content(@council_a.name)
    expect(page).to have_content(@council_z.name)
  end

  it "displays a filter box" do
    expect(page).to have_selector(".js-gem-c-table__filter")
  end

  describe "for each local authority" do
    it "an edit link points to the edit form for that council/interaction" do
      expect(page).to have_link "Edit", href: edit_link_path(@council_a, @service, @link1.service_interaction.interaction)
    end

    it "the Service name is printed" do
      expect(page).to have_text @service.label
    end

    it "shows the link status as 'Good' when the status is 200" do
      expect(page).to have_text "#{@council_a.name} Good"
    end

    it "shows the link status as 'Broken: 404 error (page not found)' when the status is 404" do
      expect(page).to have_text "#{@council_z.name} Broken: 404 error (page not found)"
    end
  end

  context "when the service doesn't exist" do
    it "returns a 404" do
      visit service_path("bed-pans")
      expect(page.status_code).to eq(404)
    end
  end
end
