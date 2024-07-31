RSpec.describe "Broken Links Page", type: :request do
  include AuthenticationControllerHelpers

  context "with a gds editor" do
    before do
      login_as_gds_editor
    end

    it "shows the page" do
      get "/"

      expect(response).to have_http_status(:ok)
    end
  end

  context "with a department editor" do
    before do
      login_as_stub_user
    end

    it "does not show the page" do
      get "/"

      expect(response).to have_http_status(:forbidden)
    end
  end
end
