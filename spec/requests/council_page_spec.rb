RSpec.describe "Council page", type: :request do
  include AuthenticationControllerHelpers

  context "with GDS Editor permission" do
    before do
      login_as_gds_editor
    end

    it "shows the page" do
      get "/local_authorities"

      expect(response).to have_http_status(200)
    end
  end

  context "without GDS Editor permission" do
    before do
      login_as_stub_user
    end

    it "redirects to the services path" do
      get "/local_authorities"

      expect(response).to redirect_to(services_path)
    end
  end
end
