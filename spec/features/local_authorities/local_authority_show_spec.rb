require 'rails_helper'

feature "The local authority show page" do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @local_authority = create(:district_council)
    visit local_authority_path(local_authority_slug: @local_authority.slug)
  end

  it 'has a list of breadcrumbs pointing back to the authority that lead us here' do
    within '.breadcrumb' do
      expect(page).to have_link 'Local links', href: root_path
      expect(page).to have_text @local_authority.name
    end
  end

  describe "with no local authority homepage url" do
    it "renders the local authority services page successfully" do
      ni_local_authority = create(:district_council)
      visit local_authority_path(local_authority_slug: ni_local_authority.slug)
      expect(page.status_code).to eq(200)

      within(:css, ".page-title") do
        expect(page).not_to have_link("/local_authorities/#{ni_local_authority.slug}/services")
      end
    end

    it "displays 'No link'" do
      @local_authority.homepage_url = nil
      @local_authority.save
      visit local_authority_path(local_authority_slug: @local_authority.slug)
      within(:css, ".page-title") do
        expect(page).to have_content('No link')
      end
    end

    it "does not display 'Link not checked'" do
      @local_authority.homepage_url = nil
      @local_authority.save
      visit local_authority_path(local_authority_slug: @local_authority.slug)
      within(:css, ".page-title") do
        expect(page).not_to have_content('Link not checked')
      end
    end
  end

  describe "with services present" do
    before do
      @service = create(:service, :all_tiers)
      @disabled_service = create(:disabled_service)
      @good_link = create_service_interaction_link(@service, 200)
      @disabled_link = create_service_interaction_link(@disabled_service, 200)
      @broken_link = create_service_interaction_link(@service, 500)
      visit local_authority_path(@local_authority)
    end

    let(:http_status) { 200 }

    it 'shows a count of the number of all links for enabled services' do
      within('thead') do
        expect(page).to have_content "3 links"
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

    it "shows only the enabled services provided by the authority according to its tier with links to their individual pages" do
      expect(page).to have_content 'Services and links'
      expect(page).to have_text(@good_link.service.label)
    end

    it "does not show the disabled service interaction" do
      expect(page).not_to have_content(@disabled_service.label)
    end

    it "shows each service's LGSL codes in the table" do
      expect(page).to have_content 'Code'
      expect(page).to have_css('td.lgsl', text: @good_link.service.lgsl_code)
    end

    it 'shows the link status as Good Link when the status is 200' do
      within(:css, "tr[data-interaction-id=\"#{@good_link.interaction.id}\"]") do
        expect(page).to have_text 'Good'
      end
    end

    it 'shows the link last checked details' do
      expect(page).to have_text @good_link.link_last_checked
    end

    it 'should have a link to Edit Link' do
      expect(page).to have_link 'Edit link', href: edit_link_path(@local_authority, @service, @good_link.interaction)
    end

    context 'editing a link' do
      it 'returns you to the correct page after updating a link' do
        within('.table') { click_on('Edit link', match: :first) }
        fill_in('link_url', with: 'http://angus.example.com/link-to-change')
        click_on('Update')

        expect(page.current_path).to eq(local_authority_path(@local_authority))
      end

      it 'returns you to the correct page after cancelling the editing of a link' do
        within('.table') { click_on('Edit link', match: :first) }
        click_on('Cancel')

        expect(page.current_path).to eq(local_authority_path(@local_authority))
      end
    end

    it 'shows the status of broken links' do
      expect(page).to have_text "500"
    end

    describe 'broken links' do
      before do
        click_link "Broken links"
      end

      it 'shows non-200 status links' do
        expect(page).to have_link @broken_link.url
      end

      it 'doesn\'t show 200 status links' do
        expect(page).not_to have_link @good_link.url
      end
    end

    describe 'good links' do
      before do
        click_link "Good links"
      end

      it 'shows 200 status links' do
        expect(page).to have_link @good_link.url
      end

      it 'doesn\'t show non-200 status links' do
        expect(page).not_to have_link @broken_link.url
      end
    end
  end

  def create_service_interaction_link(service, http_status)
    service_interaction = create(:service_interaction, service: service)

    create(:link, local_authority: @local_authority, service_interaction: service_interaction, status: http_status)
  end
end
