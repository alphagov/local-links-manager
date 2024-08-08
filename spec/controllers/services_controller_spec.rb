RSpec.describe ServicesController, type: :controller do
  describe "GET #index" do
    # context "when there is missing data" do
    #   it "returns http server error" do
    #     login_as_stub_user
    #     expect { get :index }.to raise_error "Missing Data"
    #   end
    # end

    context "when there is sufficient data" do
      it "returns http succcess" do
        login_as_stub_user
        create(:service)
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET #show" do
    it "returns http success" do
      login_as_gds_editor
      service = create(:service)
      get :show, params: { service_slug: service.slug }
      expect(response).to have_http_status(200)
    end
  end

  describe "GET #download_links_form" do
    it "returns a success response" do
      login_as_gds_editor
      service = create(:service)
      get :download_links_form, params: { service_slug: service.slug }
      expect(response).to be_successful
    end
  end

  describe "POST #download_links_csv" do
    let(:service) { create(:service) }
    let(:exported_data) { "some_data" }

    before do
      allow_any_instance_of(LocalLinksManager::Export::ServiceLinksExporter).to receive(:export_links).and_return(exported_data)
    end

    it "returns a success response" do
      login_as_gds_editor
      post :download_links_csv, params: { service_slug: service.slug }
      expect(response).to be_successful
    end
  end
end
