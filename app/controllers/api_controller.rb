require "local_links_manager/link_resolver"

class ApiController < ApplicationController
  skip_before_action :authenticate_user!

  def link
    return render json: {}, status: :bad_request if missing_required_params_for_link?
    return render json: {}, status: :not_found if missing_objects_for_link?

    link = LocalLinksManager::LinkResolver.new(authority, service, interaction).resolve

    render json: LinkApiResponsePresenter.new(authority, link).present
  end

  def local_authority
    return render json: {}, status: :bad_request if missing_required_params_for_local_authority?
    return render json: {}, status: :not_found if missing_objects_for_local_authority?

    render json: LocalAuthorityApiResponsePresenter.new(authority).present
  end

private

  def missing_required_params_for_link?
    (params[:authority_slug].blank? && params[:gss].blank?) || params[:lgsl].blank?
  end

  def missing_required_params_for_local_authority?
    params[:authority_slug].blank? && params[:gss].blank?
  end

  def missing_objects_for_link?
    authority.nil? || service.nil?
  end

  def missing_objects_for_local_authority?
    authority.nil?
  end

  def authority
    @authority ||= if params[:authority_slug]
                     LocalAuthority.find_by(slug: params[:authority_slug])
                   elsif params[:gss]
                     LocalAuthority.find_by(gss: params[:gss])
                   end
  end

  def service
    @service ||= Service.find_by(lgsl_code: params[:lgsl])
  end

  def interaction
    @interaction ||= Interaction.find_by(lgil_code: params[:lgil])
  end
end
