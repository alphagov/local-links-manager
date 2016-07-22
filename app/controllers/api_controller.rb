class ApiController < ApplicationController
  def service_interaction_for_local_authority
    @authority = LocalAuthority.find_by_slug!(params[:authority_slug])
    @service = Service.find_by(lgsl_code: params[:lgsl])
    interactions = @service.interactions
    @link = links.detect { |l| interactions.first.service_interactions.first.id == l.service_interaction.id }

    render json: local_interaction_response
  end

private

  def local_interaction_response
    {
      "local_authority"=>{
        "name"=>@authority.name,
      },
      "local_interaction"=>{
        "url"=>@link.url
      }
    }
  end

  def links
    @_links ||= @authority.links.for_service(@service)
  end
end

