RSpec.describe "Services Page" do
  before do
    create(:service, label: "Aardvark Wardens", organisation_slugs: %w[department-of-aardvarks])
  end

  context "as a gds editor" do
    before { login_as_gds_editor }

    it "shows all the services" do
      visit "/services"

      expect(page).to have_content("Aardvark Wardens")
    end
  end

  context "as a department user" do
    before { login_as_department_user }

    it "does not show Aardvark Wardens service" do
      visit "/services"

      expect(page).not_to have_content("Aardvark Wardens")
    end
  end

  context "as a user from the owning department" do
    before { login_as_department_user(organisation_slug: "department-of-aardvarks") }

    it "shows the related services only" do
      visit "/services"

      expect(page).to have_content("Aardvark Wardens")
    end
  end
end
