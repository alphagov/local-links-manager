Rails.application.routes.draw do
  root to: 'local_authorities#index'

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  resources 'local_authorities', only: [:index, :show], param: :local_authority_slug

  resources 'services', only: [:index, :show], param: :service_slug

  scope '/local_authorities/:local_authority_slug/services/:service_slug' do
    root to: 'links#index', as: 'link_index'
    resource ':interaction_slug', only: [:edit, :update, :destroy], controller: 'links', as: 'link'
  end

  get '/check_homepage_links_status.csv', to: 'links#homepage_links_status_csv'
  get '/check_links_status.csv', to: 'links#links_status_csv'

  get '/api/link', to: 'api#link'

  get '/api/local-authority', to: 'api#local_authority'

  # Serve the static CSV using NGINX instead of a controller
  get '/links-export', to: redirect('data/links_to_services_provided_by_local_authorities.csv')

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
