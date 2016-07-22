class InteractionsController < ApplicationController
  def show
    sanitize_service_slug_param
    sanitize_interaction_slug_param

    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by_slug!(params[:local_authority_slug]))
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = @service.interactions
    @link = presented_links.detect { |l| @interactions.first.service_interactions.first.id == l.service_interaction.id }

    # Should have a method like?
    # links = @authority.links.for_service_interaction(@service, @interaction)

    response = {
      "local_authority"=>{
        "name"=>@authority.name,
      },
      "local_interaction"=>{
        "url"=>@link.url
      }
    }
    render :json => response
  end

  def index
    @authority = LocalAuthorityPresenter.new(LocalAuthority.find_by_slug!(params[:local_authority_slug]))
    @service = Service.find_by_slug!(params[:service_slug])
    @interactions = presented_interactions
  end

private

  def presented_interactions
    @service.interactions.map do |interaction|
      InteractionPresenter.new(interaction, link_for_interaction(interaction))
    end
  end

  def link_for_interaction(interaction)
    presented_links.detect { |link| link.interaction == interaction }
  end

  def presented_links
    @_links ||= @authority.links.for_service(@service).map { |link| LinkPresenter.new(link) }
  end

  def sanitize_service_slug_param
    service = Service.find_by(lgsl_code: params[:service_slug])
    params[:service_slug] = service.slug if service
  end

  def sanitize_interaction_slug_param
    interaction = Interaction.find_by(lgil_code: params[:slug])
    params[:interaction_slug] = interaction.slug if interaction
  end
end


