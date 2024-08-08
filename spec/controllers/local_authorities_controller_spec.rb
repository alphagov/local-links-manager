RSpec.describe LocalAuthoritiesController, type: :controller do
  describe "GET #index" do
    context "when there is sufficient data" do
      it "returns http succcess" do
        login_as_gds_editor
        create(:local_authority)
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET #show" do
    before do
      @local_authority = create(:local_authority, name: "Angus")
      @service = create(:service, label: "Service 1", lgsl_code: 1)
    end

    it "returns http success" do
      login_as_gds_editor
      get :show, params: { local_authority_slug: @local_authority.slug, service_slug: @service.slug }
      expect(response).to have_http_status(200)
    end
  end

  describe "GET #edit_url" do
    before do
      @local_authority = create(:local_authority, name: "Angus")
      @service = create(:service, label: "Service 1", lgsl_code: 1)
    end

    it "returns http success" do
      login_as_gds_editor
      get :edit_url, params: { local_authority_slug: @local_authority.slug }
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #update" do
    before do
      @local_authority = create(:local_authority, name: "Angus")
      @service = create(:service, label: "Service 1", lgsl_code: 1)
    end

    it "returns http redirect" do
      login_as_gds_editor
      post :update, params: { local_authority_slug: @local_authority.slug, homepage_url: "http://www.example.com/new-homepage" }
      expect(response).to have_http_status(302)
      @local_authority.reload
      expect(@local_authority.homepage_url).to eq("http://www.example.com/new-homepage")
    end
  end

  describe "GET bad_homepage_url_and_status_csv" do
    it "retrieves HTTP success" do
      login_as_gds_editor
      get :bad_homepage_url_and_status_csv
      expect(response).to have_http_status(200)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  describe "GET download_links_csv" do
    before do
      @local_authority = create(:local_authority)
    end

    it "retrieves HTTP success" do
      login_as_gds_editor
      get(
        :download_links_csv,
        params: {
          local_authority_slug: @local_authority.slug,
          links_status_checkbox: %w[ok broken caution missing pending],
        },
      )
      expect(response).to have_http_status(200)
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  describe "POST upload_links_csv" do
    context "with a valid CSV" do
      before { @local_authority = create(:local_authority, gss: "S1") }
      let(:path) { Rails.root.join("spec/lib/local-links-manager/import/fixtures/imported_links.csv") }
      let(:csv) { Rack::Test::UploadedFile.new(path, "text/csv", true) }
      let(:url_regex) { /http:\/\/.+\/local_authorities\/#{@local_authority.slug}/ }

      it "retrieves HTTP found" do
        login_as_gds_editor
        post(:upload_links_csv, params: { local_authority_slug: @local_authority.slug, csv: })

        expect(response.status).to eq(302)
        expect(response.location).to match(url_regex)
        expect(response.headers["Content-Type"]).to eq("text/html; charset=utf-8")
      end
    end

    context "with errors in the CSV" do
      before do
        login_as_gds_editor
        interaction = create(:interaction, lgil_code: 1)
        6.times do |i|
          service = create(:service, lgsl_code: i + 1)
          create(:service_interaction, service:, interaction:)
        end
      end

      let(:local_authority) { create(:local_authority, gss: "S1") }
      let(:fixture_path) { "spec/lib/local-links-manager/import/fixtures/" }

      it "shows the all error message if all lines are broken" do
        csv = Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "imported_links_all_errors.csv"), "text/csv", true)
        post(:upload_links_csv, params: { local_authority_slug: local_authority.slug, csv: })
        expect(flash[:danger]).to eq("Errors on all lines. Ensure a New URL column exists, with all rows either blank or a valid URL")
      end

      it "shows the many error message if many lines are broken" do
        csv = Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "imported_links_many_errors.csv"), "text/csv", true)
        post(:upload_links_csv, params: { local_authority_slug: local_authority.slug, csv: })
        expect(flash[:danger].first).to eq("74 Errors detected. Please ensure a valid entry in the New URL column for lines (showing first 50):")
      end

      it "shows the few error message if few lines are broken" do
        csv = Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "imported_links_few_errors.csv"), "text/csv", true)
        post(:upload_links_csv, params: { local_authority_slug: local_authority.slug, csv: })
        expect(flash[:danger].first).to eq("2 Errors detected. Please ensure a valid entry in the New URL column for lines:")
      end

      it "shows the nothing to import info if it didn't import anything" do
        csv = Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "imported_links_nothing_to_import.csv"), "text/csv", true)
        post(:upload_links_csv, params: { local_authority_slug: local_authority.slug, csv: })
        expect(flash[:info]).to eq("No records updated. (If you were expecting updates, check the format of the uploaded file)")
      end
    end
  end
end
