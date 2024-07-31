RSpec.describe "ServicesPage" do
  include AuthenticationControllerHelpers
  before do
    create(:service, label: "Aardvark Wardens", organisation_slugs: %w[department-of-aardvarks])
  end

  context "with a gds editor" do
    before do
      login_as_gds_editor
    end

    it "shows all the services" do
      visit "/services"

      expect(page).to have_content("Aardvark Wardens")
    end
  end

  context "with a user from some other department" do
    before do
      login_as_stub_user
    end

    it "does not show Aardvark Wardens service" do
      visit "/services"

      expect(page).not_to have_content("Aardvark Wardens")
    end
  end

  context "with a user from a particular department" do
    before do
      login_as_user_from(organisation_slug: "department-of-aardvarks")
    end

    it "shows the related services only" do
      visit "/services"

      expect(page).to have_content("Aardvark Wardens")
    end
  end
end
