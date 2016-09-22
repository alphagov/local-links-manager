# http://local-links-manager.dev.gov.uk/local_authorities/aberdeen/services/name/interactions
Rails.application.routes.draw do
  root to: 'local_authorities#index'

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  resources "local_authorities", only: [:index, :edit, :update], param: :slug do
    resources "services", only: [:index], param: :slug do
      resources "interactions", only: [:index], param: :slug do
        resource "links", only: [:edit, :update, :destroy]
      end
    end
  end

  get '/check_homepage_links_status.csv', to: 'links#homepage_links_status_csv'
  get '/check_links_status.csv', to: 'links#links_status_csv'

  get '/api/link', to: 'api#link'

  get '/api/local-authority', to: 'api#local_authority'

  # Serve the static CSV using NGINX instead of a controller
  get '/links-export', to: redirect('data/links_to_services_provided_by_local_authorities.csv')

  namespace :v2 do
    root to: redirect('v2/broken-links')
    get '/broken-links', to: 'home#broken_links'
    get '/local-authorities', to: 'home#local_authorities'
    get '/services', to: 'home#services'
  end

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
