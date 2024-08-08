Rails.application.routes.draw do
  root to: "links#index"

  mount GovukPublishingComponents::Engine, at: "/component-guide" if Rails.env.development?

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::Redis,
  )

  resources "local_authorities", only: %i[index show update], param: :local_authority_slug do
    member do
      get "download_links_form"
      post "download_links_csv"
      get "upload_links_form"
      post "upload_links_csv"
      get "edit_url"
    end
  end

  resources "services", only: %i[index show], param: :service_slug do
    member do
      get "download_links_form"
      post "download_links_csv"
      get "upload_links_form"
      post "upload_links_csv"
      get "update-owner-form"
      patch "update-owner"
    end
  end

  get "/local_authorities/:local_authority_slug/services/:service_slug", to: redirect("/local_authorities/%{local_authority_slug}")

  scope "/local_authorities/:local_authority_slug/services/:service_slug" do
    resource ":interaction_slug", only: %i[edit update destroy], controller: "links", as: "link"
  end

  get "/check_homepage_links_status.csv", to: "links#homepage_links_status_csv"
  get "/check_links_status.csv", to: "links#links_status_csv"

  get "/bad_links_url_status.csv", to: "links#bad_links_url_and_status_csv"

  get "/bad_homepage_url_status.csv", to: "local_authorities#bad_homepage_url_and_status_csv"

  get "/api/link", to: "api#link"

  get "/api/local-authority", to: "api#local_authority"

  post "/link-check-callback", to: "webhooks#link_check_callback", as: :link_checker_webhook
end
