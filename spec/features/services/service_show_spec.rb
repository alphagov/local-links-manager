feature "The services show page" do
  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: %w[signin])

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
    expect(page).to have_selector(".breadcrumb")
  end

  it "displays the name of the service" do
    expect(page).to have_content(@service.label)
    expect(page).to have_content(@service.lgsl_code)
  end

  it "shows each of the councils which provide this service" do
    expect(page).to have_content(@council_a.name)
    expect(page).to have_content(@council_z.name)
  end

  it "lists the councils in alphabetic order" do
    expect(@council_a.name).to appear_before(@council_z.name)
  end

  it "shows a count of the number of broken links" do
    within("thead") do
      expect(page).to have_content "2 links"
    end
  end

  it "displays a filter box" do
    expect(page).to have_selector(".filter-control")
  end

  it "has navigation tabs" do
    expect(page).to have_selector(".link-nav")
    within(".link-nav") do
      expect(page).to have_link "Broken links"
      expect(page).to have_link "All links"
    end
  end

  describe "broken links" do
    before do
      click_link "Broken links"
    end

    it "shows non-200 status links" do
      expect(page).to have_link @link2.url
    end

    it "doesn't show 200 status links" do
      expect(page).not_to have_link @link1.url
    end
  end

  describe "for each local authority" do
    it "the Local Authority name is linked to the council specific page" do
      for_local_authority(@council_a) do
        expect(page).to have_link @council_a.name, href: local_authority_path(@council_a)
      end
    end

    it "the Service name is linked to the service page for that council" do
      for_local_authority_interactions(@council_a, @link1.interaction) do
        expect(page).to have_text @service.label
      end
    end

    it "the Interaction name is printed" do
      for_local_authority_interactions(@council_a, @link1.interaction) do
        expect(page).to have_text @link1.interaction.label
      end
    end

    it "shows the link status as 'Good' when the status is 200" do
      for_local_authority_interactions(@council_a, @link1.interaction) do
        expect(page).to have_text "Good"
      end
    end

    it "shows the link status as 'Broken: 404 error (page not found)' when the status is 404" do
      for_local_authority_interactions(@council_z, @link2.interaction) do
        expect(page).to have_text "Broken: 404 error (page not found)"
      end
    end

    it "shows the link last checked details" do
      for_local_authority_interactions(@council_a, @link1.interaction) do
        expect(page).to have_text "Link not checked"
      end
    end

    it "should have a link to Edit Link" do
      for_local_authority_interactions(@council_a, @link1.interaction) do
        expect(page).to have_link "Edit link", href: edit_link_path(@council_a, @service, @link1.interaction)
      end
    end
  end

  context "when the service doesn't exist" do
    it "returns a 404" do
      expect { visit service_path("bed-pans") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  def for_local_authority(council, &block)
    within(".header-row[data-local-authority-id=\"#{council.id}\"]", &block)
  end

  def for_local_authority_interactions(council, interaction = nil, &block)
    if interaction
      within("[data-local-authority-id=\"#{council.id}\"][data-service-id=\"#{@service.id}\"][data-interaction-id=\"#{interaction.id}\"]", &block)
    else
      within("[data-local-authority-id=\"#{council.id}\"][data-service-id=\"#{@service.id}\"]", &block)
    end
  end
end
