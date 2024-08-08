feature "The local authorities index page" do
  include AuthenticationControllerHelpers

  before do
    login_as_gds_editor

    @angus = create(:local_authority, name: "Angus")
    @zorro = create(:local_authority, name: "Zorro Council", status: "caution", problem_summary: "Redirect", broken_link_count: 1)
    @hidden = create(:local_authority, name: "Hidden Council", active_end_date: Time.zone.now - 1.day)
    visit local_authorities_path(filter: %w[only_active])
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector(".govuk-breadcrumbs__list")
  end

  it "displays a filter box" do
    expect(page).to have_selector(".js-gem-c-table__filter")
  end

  it "shows the available local authorities" do
    expect(page).to have_content "Councils (2)"
  end

  it "shows links to each local authority page" do
    expect(page).to have_link("Edit Angus", href: local_authority_path(@angus.slug, filter: "broken_links"), exact: true)
    expect(page).to have_link("Edit Zorro Council", href: local_authority_path(@zorro.slug, filter: "broken_links"), exact: true)
  end

  it "shows the count of broken links for each local authority" do
    expect(page).to have_content "Angus Not checked Yes 0"
    expect(page).to have_content "Zorro Council Note: Redirect Yes 1"
  end

  it "does not show retired authorities by default" do
    expect(page).not_to have_content "Hidden Council Not checked No 0"
  end

  describe "clicking on the Edit link on the index page" do
    it "takes you to the show page for that LA" do
      first("tbody").first("tr").click_link("Edit")
      expect(current_path).to eq(local_authority_path(@zorro.slug))
    end
  end

  describe "clicking the filter box to show only broken homepages" do
    it "filters out the working councils" do
      check("Homepage problems")
      click_on("Update")
      expect(page).to have_content "Councils (1)"
      expect(page).not_to have_content "Angus Not checked Yes 0"
      expect(page).to have_content "Zorro Council Note: Redirect Yes 1"
    end
  end

  describe "clicking the filter box to include retired councils" do
    it "shows the retired councils" do
      uncheck("Active councils")
      click_on("Update")
      expect(page).to have_content "Councils (3)"
      expect(page).to have_content "Angus Not checked Yes 0"
      expect(page).to have_content "Zorro Council Note: Redirect Yes 1"
      expect(page).to have_content "Hidden Council Not checked No 0"
    end
  end
end
