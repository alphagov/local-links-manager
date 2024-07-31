feature "The broken links page" do
  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: ["signin", "GDS Editor"])

    @service = create(:service, :all_tiers)
    @service_interaction = create(:service_interaction, service: @service)
    @council_a = create(:unitary_council, name: "council-aaa")
    @council_b = create(:county_council, name: "council-bbb")
    @council_c = create(:district_council, name: "council-ccc")
    @council_d = create(:district_council, name: "council-ddd")
    @link1 = create(:link, local_authority: @council_a, service_interaction: @service_interaction, status: "ok", link_last_checked: "1 day ago", analytics: 911)
    @link2 = create(:link, local_authority: @council_b, service_interaction: @service_interaction, status: "broken", analytics: 37, problem_summary: "A problem")
    @link3 = create(:link, local_authority: @council_c, service_interaction: @service_interaction, status: "broken", analytics: 823, problem_summary: "A problem")
    @link4 = create(:missing_link, local_authority: @council_d, service_interaction: @service_interaction)
    visit "/"
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector(".govuk-breadcrumbs__list")
  end

  it "displays the title of the local transaction for each broken link" do
    expect(page).to have_content("A title")
  end

  it "shows the council name for each broken link" do
    expect(page).to have_content(@council_b.name)
    expect(page).to have_content(@council_c.name)
    expect(page).to have_content(@council_d.name)
  end

  it "shows missing status" do
    expect(page).to have_content "Missing"
  end

  it "lists the links prioritised by analytics count" do
    expect(@council_c.name).to appear_before(@council_b.name)
  end

  it "shows a count of the number of broken links" do
    within("#content") do
      expect(page).to have_content "Broken Links (showing top 200 of 3)"
    end
  end

  it "displays a filter box" do
    expect(page).to have_selector(".js-gem-c-table__filter")
  end
end
