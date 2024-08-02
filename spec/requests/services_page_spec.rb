RSpec.describe "ServicesPage" do
    include AuthenticationControllerHelpers
    before do
      create(:service, label: "Aardvark Wardens", organisation_slugs: %w[department-of-aardvarks])
    end

    context "with a user from a particular department" do
      before do
        login_as_user_from(organisation_slug: "department-of-aardvarks")
      end
  
      it "shows the page of the particular department" do
        get "/services/aardvark-wardens"
  
        expect(response).to have_http_status(:ok)
      end
    end

    context "with a user from a different department" do
        before do
          login_as_stub_user
        end
    
        it "does not show the page of the department" do
          get "/services/aardvark-wardens"
    
          expect(response).to have_http_status(:forbidden)
        end
      end
  end
  