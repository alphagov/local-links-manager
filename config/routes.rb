# http://local-links-manager.dev.gov.uk/local_authorities/aberdeen/services/name/interactions
Rails.application.routes.draw do
  root to: 'local_authorities#index'

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  resources "local_authorities", only: [:index, :edit, :update], param: :slug do
    resources "services", only: [:index], param: :slug do
      resources "interactions", only: [:index, :show], param: :slug do
        resource "links", only: [:edit, :update, :destroy]
      end
    end
  end

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
