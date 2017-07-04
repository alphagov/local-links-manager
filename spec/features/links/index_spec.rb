require 'rails_helper'

feature 'The broken links page' do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])

    @service = create(:service, :all_tiers)
    @service_interaction = create(:service_interaction, service: @service)
    @council_a = create(:unitary_council, name: 'aaa')
    @council_m = create(:county_council, name: 'mmm')
    @council_z = create(:district_council, name: 'zzz')
    @link_1 = create(:link, local_authority: @council_a, service_interaction: @service_interaction, status: 200, link_last_checked: '1 day ago', analytics: 911)
    @link_2 = create(:link, local_authority: @council_m, service_interaction: @service_interaction, status: 404, analytics: 37)
    @link_3 = create(:link, local_authority: @council_z, service_interaction: @service_interaction, status: 503, analytics: 823)

    @council_x = create(:district_council, name: 'xxx')
    @link_4 = create(:link, local_authority: @council_x, service_interaction: @service_interaction, url: nil, analytics: 999)
    visit '/'
  end

  it "has a breadcrumb trail" do
    expect(page).to have_selector('.breadcrumb')
  end

  it 'displays the title of the local transaction for each broken link' do
    expect(page).to have_content('A title')
  end

  it 'displays the LGSL code for each broken link' do
    expect(page).to have_content(@service.lgsl_code)
  end

  it 'shows the council name for each broken link' do
    expect(page).to have_content(@council_m.name)
    expect(page).to have_content(@council_z.name)
  end

  it 'shows non-200 status links' do
    expect(page).to have_link @link_2.url
  end

  it 'shows missing links' do
    expect(page).to have_text "No URL"
  end

  it 'doesn\'t show 200 status links' do
    expect(page).not_to have_link @link_1.url
  end

  it 'lists the links prioritised by analytics count' do
    expect(@council_z.name).to appear_before(@council_m.name)
  end

  it 'shows a count of the number of broken links' do
    within('thead') do
      expect(page).to have_content "3 broken links"
    end
  end

  it "displays a filter box" do
    expect(page).to have_selector('.filter-control-full-width')
  end

  it 'has navigation tabs' do
    expect(page).to have_selector('.nav-tabs')
    within('.nav-tabs') do
      expect(page).to have_link 'Broken links'
      expect(page).to have_link 'Councils'
      expect(page).to have_link 'Services'
    end
  end
end
