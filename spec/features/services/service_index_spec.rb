feature "The services index page" do
  include AuthenticationControllerHelpers

  before do
    login_as_gds_editor

    @aardvark = create(:service, label: "Aardvark Wardens")
    @zebra = create(:service, label: "Zebra Fouling", broken_link_count: 1)
    si = create(:service_interaction, service: @aardvark, govuk_title: "SI1")
    create(:link, service_interaction: si, analytics: 30)
    si2 = create(:service_interaction, service: @aardvark, govuk_title: "SI2")
    create(:link, service_interaction: si2, analytics: 25)
    create(:disabled_service)
    visit services_path
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector(".govuk-breadcrumbs__list")
  end

  it "displays a filter box" do
    expect(page).to have_selector(".js-gem-c-table__filter")
  end

  it "shows enabled services sorted by broken link count" do
    expect(page).to have_content("Services (2)")
    expect(page).to have_content("0 Zebra Fouling Not used on GOV.UK #{@zebra.lgsl_code} 1")
    expect(page).to have_content("55 Aardvark Wardens SI1SI2 #{@aardvark.lgsl_code} 0")
    expect("Zebra Fouling").to appear_before("Aardvark Wardens")
  end
end
