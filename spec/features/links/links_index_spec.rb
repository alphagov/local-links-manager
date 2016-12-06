require 'rails_helper'

feature "The links index page for a service provided by a local authority" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = create(:county_council)
    @service = create(:service, :county_unitary)
    interaction = create(:interaction)
    @service_interaction = create(:service_interaction, service_id: @service.id, interaction_id: interaction.id)
    @link = create(:link, local_authority: @local_authority, service_interaction: @service_interaction)
    visit link_index_path(local_authority_slug: @local_authority.slug, service_slug: @service.slug)
  end

  it "displays the LGSL code" do
    expect(page).to have_content("Service code #{@service.lgsl_code}")
  end

  it 'has a list of breadcrumbs pointing back to the authority and service that lead us here' do
    within '.breadcrumb' do
      expect(page).to have_link 'Local links', href: root_path
      expect(page).to have_link @local_authority.name, href: local_authority_path(@local_authority.slug)
      expect(page).to have_text @service.label
    end
  end

  it "shows the local authority name" do
    expect(page).to have_css('h1', text: @local_authority.name)
  end

  it "shows the local authority links for the service" do
    expect(page).to have_content(@link.url)
  end
end
