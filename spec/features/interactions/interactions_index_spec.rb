require 'rails_helper'

feature "The interactions index page for a service provided by a local authority" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = FactoryGirl.create(:local_authority, :county_tier, name: 'Angus')
    @service_1 = FactoryGirl.create(:service, :county, label: 'Service 1')
    visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug)
  end

  it "displays the LGSL code" do
    expect(page).to have_content("LGSL #{@service_1.lgsl_code}")
  end

  it 'has a list of breadcrumbs pointing back to the authority and service that lead us here' do
    within '.breadcrumb' do
      expect(page).to have_link 'Local Authorities', href: local_authorities_path
      expect(page).to have_link 'Angus', href: local_authority_services_path(@local_authority.slug)
      expect(page).to have_text 'Service 1'
    end
  end

  describe "with no interactions present" do
    it "shows a message that no interactions are present" do
      expect(page).to have_content("No local interactions found")
    end
  end

  describe "with interactions present" do
    before do
      @interaction_1 = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 3)
      @interaction_2 = FactoryGirl.create(:interaction, label: 'Interaction 2', lgil_code: 4)
      @service_interaction = FactoryGirl.create(:service_interaction, service_id: @service_1.id, interaction_id: @interaction_1.id)
      visit local_authority_service_interactions_path(local_authority_slug: @local_authority.slug, service_slug: @service_1.slug)
    end

    it "shows the local authority name and homepage_url" do
      expect(page).to have_css('h1', text: @local_authority.name)
      expect(page).to have_link(@local_authority.homepage_url)
    end

    it "shows the available interactions for the service" do
      expect(page).to have_content('Local Government Interactions (1)')
      expect(page).to have_content('Interaction 1')
      # Interaction 2 does not belong to service 1, so don't display it.
      expect(page).not_to have_content('Interaction 2')
    end

    it "shows each service interaction's LGIL code" do
      expect(page).to have_content 'LGIL Code'
      expect(page).to have_css('td.lgil_code', text: 3)
      expect(page).not_to have_css('td.lgil_code', text: 4)
    end
  end
end
