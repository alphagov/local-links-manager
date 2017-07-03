require 'rails_helper'

feature 'The links for a local authority' do
  before do
    User.create(email: 'user@example.com', name: 'Test User', permissions: ['signin'])
    @time = Timecop.freeze("2016-07-14 11:34:09 +0100")
    @local_authority = create(:local_authority, status: '200', link_last_checked: @time - (60 * 60))
    @service = create(:service)
    @interaction_1 = create(:interaction)
    @interaction_2 = create(:interaction)
    @service_interaction_1 = create(:service_interaction, service: @service, interaction: @interaction_1)
    @service_interaction_2 = create(:service_interaction, service: @service, interaction: @interaction_2)
  end

  describe "homepage link status CSV" do
    it "should show a CSV" do
      visit '/check_homepage_links_status.csv'
      expect(page.body).to include("status,count\n")
      expect(page.body.count("\n")).to be > 1
    end
  end

  describe "interaction link status CSV" do
    before do
      create(:link, status: '200', link_last_checked: @time - (60 * 60))
    end

    it "should show a CSV" do
      visit '/check_links_status.csv'
      expect(page.body).to include("status,count\n")
      expect(page.body.count("\n")).to be > 1
    end
  end
end
