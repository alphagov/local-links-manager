RSpec.describe "Service Page" do
  before do
    create(:service, label: "Aardvark Wardens", organisation_slugs: %w[department-of-aardvarks])
  end

  describe "Visiting the page" do
    context "as an owning department user" do
      before { login_as_department_user(organisation_slug: "department-of-aardvarks") }

      it "does not show the Update Owner link" do
        visit "/services/aardvark-wardens"

        expect(page).not_to have_content("Update Owner")
      end
    end

    context "as a GDS Editor" do
      before { login_as_gds_editor }

      it "shows the Update Owner link" do
        visit "/services/aardvark-wardens"

        expect(page).to have_content("Update Owner")
      end
    end
  end

  describe "Updating the owner" do
    before { login_as_gds_editor }

    it "allows us to update the owner" do
      visit "/services/aardvark-wardens"

      expect(page).to have_content("department-of-aardvarks")
      expect(page).not_to have_content("government-digital-service")

      click_on "Update Owner"
      fill_in "Organisation Slug", with: "government-digital-service"
      click_on "Submit"

      expect(page).not_to have_content("department-of-aardvarks")
      expect(page).to have_content("government-digital-service")
    end

    it "allows us to cancel updating the owner" do
      visit "/services/aardvark-wardens"

      expect(page).to have_content("department-of-aardvarks")
      expect(page).not_to have_content("government-digital-service")

      click_on "Update Owner"
      fill_in "Organisation Slug", with: "government-digital-service"
      click_on "Cancel"

      expect(page).to have_content("department-of-aardvarks")
      expect(page).not_to have_content("government-digital-service")
    end
  end
end
