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

  def login_as_user_from(organisation_slug:)
    login_as_new(create(:user, organisation_slug:))
  end

  def login_as_gds_editor
    login_as_new(create(:user, permissions: ["GDS Editor"], organisation_slug: "government-digital-service"))
  end

  def login_as_department_user
    login_as_new(stub_user)
  end

  def login_as_stub_user
    login_as_new(stub_user)
  end
end
RSpec.configuration.include AuthenticationControllerHelpers, type: :controller
