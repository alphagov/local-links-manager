feature "The links for a local authority" do
  before do
    User.create!(email: "user@example.com", name: "Test User", permissions: ["signin", "GDS Editor"])
    @time = Timecop.freeze("2016-07-14 11:34:09 +0100")
    @local_authority = create(:local_authority, status: "ok", link_last_checked: @time - (60 * 60))
    @service = create(:service)
    @interaction1 = create(:interaction)
    @interaction2 = create(:interaction)
    @service_interaction1 = create(:service_interaction, service: @service, interaction: @interaction1)
    @service_interaction2 = create(:service_interaction, service: @service, interaction: @interaction2)
  end

  describe "when links exist for the service interaction" do
    before do
      @link1 = create(:link, local_authority: @local_authority, service_interaction: @service_interaction1, status: "ok", link_last_checked: @time - (60 * 60))
      @link2 = create(:link, local_authority: @local_authority, service_interaction: @service_interaction2)
    end

    it "returns a 404 if the supplied local authority doesn't exist" do
      visit edit_link_path(
        local_authority_slug: "benidorm",
        service_slug: @service.slug,
        interaction_slug: @interaction1.slug,
      )
      expect(page.status_code).to eq(404)
    end

    it "returns a 404 if the supplied service doesn't exist" do
      visit edit_link_path(
        local_authority_slug: @local_authority.slug,
        service_slug: "bed-pans",
        interaction_slug: @interaction1.slug,
      )
      expect(page.status_code).to eq(404)
    end

    it "returns a 404 if the supplied interaction doesn't exist" do
      visit edit_link_path(
        local_authority_slug: @local_authority.slug,
        service_slug: @service.slug,
        interaction_slug: "buccaneering",
      )
      expect(page.status_code).to eq(404)
    end
  end

  describe "homepage link status CSV" do
    it "should show a CSV" do
      visit "/check_homepage_links_status.csv"
      expect(page.body).to include("problem_summary,count,status\n")
      expect(page.body.count("\n")).to be > 1
    end
  end

  describe "interaction link status CSV" do
    before do
      create(:link, status: "ok", link_last_checked: @time - (60 * 60))
    end

    it "should show a CSV" do
      visit "/check_links_status.csv"
      expect(page.body).to include("problem_summary,count,status\n")
      expect(page.body.count("\n")).to be > 1
    end
  end
end
