RSpec.describe "Main Menu" do
  context "as a normal user" do
    before { login_as_department_user }

    it "shows only the Services menu item" do
      visit "/"

      within(".govuk-header__container") do
        expect(page).not_to have_content("Broken Links")
        expect(page).not_to have_content("Councils")
        expect(page).to have_content("Services")
      end
    end
  end

  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "shows all three menu options" do
      visit "/"

      within(".govuk-header__container") do
        expect(page).to have_content("Broken Links")
        expect(page).to have_content("Councils")
        expect(page).to have_content("Services")
      end
    end
  end
end
