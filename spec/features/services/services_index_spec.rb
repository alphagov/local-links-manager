require 'rails_helper'

feature "The services index page for a local authority" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = FactoryGirl.create(:local_authority, :district_tier, name: "Angus")
    visit local_authority_services_path(local_authority_slug: @local_authority.slug)
  end

  it 'has a list of breadcrumbs pointing back to the authority that lead us here' do
    within '.breadcrumb' do
      expect(page).to have_link 'Local Authorities', href: local_authorities_path
      expect(page).to have_text 'Angus'
    end
  end

  describe "with no local authority homepage url" do
    it "shows the 'Add link' button" do
      click_on('Edit link')
      fill_in('local_authority_homepage_url', with: '')
      click_on('Save')
      expect(page).to have_content('Homepage link has been saved.')
      expect(page).to have_link('Add link')
    end

    it "renders the local authority services page successfully" do
      ni_local_authority = FactoryGirl.create(:local_authority, name: 'Antrim and Newtownabbey Borough Council', gss: 'N09000001', snac: 'N09000001', slug: 'antrim-newtownabbey', homepage_url: nil)
      visit local_authority_services_path(local_authority_slug: ni_local_authority.slug)
      expect(page.status_code).to eq(200)

      within(:css, ".page-title") do
        expect(page).not_to have_link("/local_authorities/#{ni_local_authority.slug}/services")
      end
    end

    it "displays 'No link'" do
      @local_authority.homepage_url = nil
      @local_authority.save
      visit local_authority_services_path(local_authority_slug: @local_authority.slug)
      within(:css, ".page-title") do
        expect(page).to have_content('No link')
      end
    end

    it "does not display 'Link not checked'" do
      @local_authority.homepage_url = nil
      @local_authority.save
      visit local_authority_services_path(local_authority_slug: @local_authority.slug)
      within(:css, ".page-title") do
        expect(page).not_to have_content('Link not checked')
      end
    end
  end

  describe "with no services present" do
    it "shows a message that no services are present" do
      expect(page).to have_content 'No local services found'
    end
  end

  describe "with services present" do
    before do
      @service_1 = FactoryGirl.create(:service, :all_tiers, label: 'All councils', lgsl_code: 1, enabled: true)
      @service_2 = FactoryGirl.create(:service, :county, label: 'County and unitary only', lgsl_code: 2, enabled: true)
      @service_3 = FactoryGirl.create(:service, :district, label: 'District and unitary only', lgsl_code: 3, enabled: true)
      @service_4 = FactoryGirl.create(:service, label: 'Unknown', lgsl_code: 4, enabled: true)
      @service_5 = FactoryGirl.create(:service, :district, label: 'District and unitary disabled', lgsl_code: 5, enabled: false)
      visit local_authority_services_path(@local_authority.slug)
    end

    it "shows only the enabled services provided by the authority according to its tier with links to their individual pages" do
      expect(page).to have_content 'Local Government Services (2)'
      expect(page).to have_link('All councils', href: local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug))
      expect(page).to have_link('District and unitary only', href: local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_3.slug))
      expect(page).not_to have_link('District and unitary disabled')
    end

    it "shows each service's LGSL codes in the table" do
      expect(page).to have_content 'LGSL Code'
      expect(page).to have_css('td.lgsl_code', text: 1)
      expect(page).to have_css('td.lgsl_code', text: 3)
    end
  end
end
