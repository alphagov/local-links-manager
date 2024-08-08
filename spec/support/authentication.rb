module AuthenticationControllerHelpers
  def login_as_new(user)
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def login_as(user)
    request.env["warden"] = double(
      authenticate!: true,
      authenticated?: true,
      user:,
    )
  end

  def stub_user
    create(:user)
  end

  def login_as_department_user(organisation_slug: "random-deparment")
    login_as_new(create(:user, organisation_slug:))
  end

  def login_as_gds_editor
    login_as_new(create(:user, permissions: ["GDS Editor"], organisation_slug: "government-digital-service"))
  end

  def login_as_stub_user
    login_as_new(stub_user)
  end
end

RSpec.shared_examples "only GDS Editors can visit" do |path|
  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "shows the page" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user" do
    before { login_as_department_user }

    it "does not show the page" do
      get path

      expect(response).to redirect_to(services_path)
    end
  end
end

RSpec.shared_examples "it is forbidden to non-owners" do |path, owning_department|
  context "as a GDS Editor" do
    before { login_as_gds_editor }

    it "returns 200" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user from the owning department" do
    before { login_as_department_user(organisation_slug: owning_department) }

    it "returns 200" do
      get path

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a department user" do
    before { login_as_department_user }

    it "returns 403" do
      get path

      expect(response).to have_http_status(:forbidden)
    end
  end
end
