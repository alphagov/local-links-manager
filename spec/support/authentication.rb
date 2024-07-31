module AuthenticationControllerHelpers
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

  def login_as_gds_editor
    login_as(create(:user, permissions: ["GDS Editor"], organisation_slug: "government-digital-service"))
  end

  def login_as_stub_user
    login_as stub_user
  end
end
RSpec.configuration.include AuthenticationControllerHelpers, type: :controller
