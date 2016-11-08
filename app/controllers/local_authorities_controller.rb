class LocalAuthoritiesController < ApplicationController
  def index
    @authorities = LocalAuthority.all.order(name: :asc)
  end

  def edit
    session[:return_to_from_homepage_edit] = (request.headers["Referer"])
    @authority = LocalAuthority.find_by(slug: params[:slug])
  end

  def update
    @authority = LocalAuthority.find_by(slug: params[:slug])
    @authority.homepage_url = params[:local_authority][:homepage_url].strip
    validate_and_save(@authority)
  end

  def where_we_came_from_url
    session[:return_to_from_homepage_edit] || local_authority_services_path(local_authority_slug: params[:slug])
  end
  helper_method :where_we_came_from_url

private

  def validate_and_save(authority)
    if authority.save
      flash[:success] = "Homepage link has been saved."
      redirect_to where_we_came_from_url
    else
      flash.now[:danger] = "Please enter a valid link."
      render :edit
    end
  end
end
