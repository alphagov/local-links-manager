require 'rails_helper'

feature 'The services show page' do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])

    @service = create(:service, :all_tiers)
    service_interaction = create(:service_interaction, service: @service)
    @council_a = create(:unitary_council, name: 'aaa')
    @council_z = create(:district_council, name: 'zzz')
    @link_1 = create(:link, local_authority: @council_a, service_interaction: service_interaction, status: 200, link_last_checked: '1 day ago')
    @link_2 = create(:link, local_authority: @council_z, service_interaction: service_interaction, status: 404)
    visit service_path(@service)
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector('.breadcrumb')
  end

  it 'displays the name of the service' do
    expect(page).to have_content(@service.label)
    expect(page).to have_content(@service.lgsl_code)
  end

  it 'shows each of the councils which provide this service' do
    expect(page).to have_content(@council_a.name)
    expect(page).to have_content(@council_z.name)
  end

  it 'lists the councils in alphabetic order' do
    expect(@council_a.name).to appear_before(@council_z.name)
  end

  it 'shows a count of the number of broken links' do
    within('thead') do
      expect(page).to have_content "2 links"
    end
  end

  it "displays a filter box" do
    expect(page).to have_selector('.filter-control')
  end

  it 'has navigation tabs' do
    expect(page).to have_selector('.link-nav')
    within('.link-nav') do
      expect(page).to have_link 'Broken links'
      expect(page).to have_link 'Good links'
      expect(page).to have_link 'All links'
    end
  end

  describe 'broken links' do
    before do
      click_link "Broken links"
    end

    it 'shows non-200 status links' do
      expect(page).to have_link @link_2.url
    end

    it 'doesn\'t show 200 status links' do
      expect(page).not_to have_link @link_1.url
    end
  end

  describe 'good links' do
    before do
      click_link "Good links"
    end

    it 'shows 200 status links' do
      expect(page).to have_link @link_1.url
    end

    it 'doesn\'t show non-200 status links' do
      expect(page).not_to have_link @link_2.url
    end
  end

  describe 'for each local authority' do
    it 'the Local Authority name is linked to the council specific page' do
      for_local_authority(@council_a) do
        expect(page).to have_link @council_a.name, href: local_authority_path(@council_a)
      end
    end

    it 'the Service name is linked to the service page for that council' do
      for_local_authority_interactions(@council_a, @link_1.interaction) do
        expect(page).to have_link @service.label, href: link_index_path(@council_a, @service)
      end
    end

    it 'the Interaction name is printed' do
      for_local_authority_interactions(@council_a, @link_1.interaction) do
        expect(page).to have_text @link_1.interaction.label
      end
    end

    it 'shows the link status as Good Link when the status is 200' do
      for_local_authority_interactions(@council_a, @link_1.interaction) do
        expect(page).to have_text 'Good'
      end
    end

    it 'shows the link status as Broken Link 404 when the status is 404' do
      for_local_authority_interactions(@council_z, @link_2.interaction) do
        expect(page).to have_text 'Broken Link 404'
      end
    end

    it 'shows the link last checked details' do
      for_local_authority_interactions(@council_a, @link_1.interaction) do
        expect(page).to have_text @link_1.link_last_checked
      end
    end

    it 'should have a link to Edit Link' do
      for_local_authority_interactions(@council_a, @link_1.interaction) do
        expect(page).to have_link 'Edit link', href: edit_link_path(@council_a, @service, @link_1.interaction)
      end
    end
  end

  def for_local_authority(council)
    within(".header-row[data-local-authority-id=\"#{council.id}\"]") do
      yield
    end
  end

  def for_local_authority_interactions(council, interaction = nil)
    if interaction
      within("[data-local-authority-id=\"#{council.id}\"][data-service-id=\"#{@service.id}\"][data-interaction-id=\"#{interaction.id}\"]") do
        yield
      end
    else
      within("[data-local-authority-id=\"#{council.id}\"][data-service-id=\"#{@service.id}\"]") do
        yield
      end
    end
  end
end
