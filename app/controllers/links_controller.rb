class LinksController < ApplicationController
  before_action :load_dependencies, only: %i[edit update destroy]
  before_action :set_back_url_before_post_request, only: %i[edit update destroy]
  helper_method :back_url

  def index
    currently_broken = Link.enabled_links.broken_or_missing
    @total_broken_links = currently_broken.count
    @broken_links = currently_broken.order(analytics: :desc).limit(200)
    @breadcrumbs = [{ title: "Home", url: "/" }]
  end

  def edit
    if flash[:link_url]
      @link.url = flash[:link_url]
      @link.validate
    end

    @breadcrumbs = [{ title: "Home", url: "/" }, { title: "Edit Link", url: request.path }]
  end

  def update
    @link.url = link_url
    @link.not_provided_by_authority = link_not_provided_by_authority

    if @link.save
      @link.local_authority.update_broken_link_count
      @link.service.update_broken_link_count
      redirect
    else
      flash[:danger] = "Please enter a valid link."
      redirect_back
    end
  end

  def destroy
    @link.make_missing
    redirect("deleted")
  end

  def homepage_links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.homepage_links_status_csv
    send_data data, filename: "homepage_links_status.csv"
  end

  def links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.links_status_csv
    send_data data, filename: "links_status.csv"
  end

  def bad_links_url_and_status_csv
    data = LocalLinksManager::Export::BadLinksUrlAndStatusExporter.bad_links_url_and_status_csv
    send_data data, filename: "bad_links_url_status.csv"
  end

private

  def load_dependencies
    @local_authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
    @interaction = Interaction.find_by!(slug: params[:interaction_slug])
    @service = Service.find_by!(slug: params[:service_slug])
    @link = Link.retrieve_or_build(params)
  end

  def set_back_url_before_post_request
    flash[:back] = back_url
  end

  def back_url
    flash[:back] ||
      request.env["HTTP_REFERER"] ||
      local_authority_path(local_authority_slug: params[:local_authority_slug])
  end

  def link_url
    params[:url].strip
  end

  def link_not_provided_by_authority
    params[:not_provided_by_authority].present? && params[:not_provided_by_authority] == "on"
  end

  def redirect_back
    flash[:link_url] = link_url
    redirect_to edit_link_path(@local_authority, @service, @interaction)
  end

  def redirect(action = "saved")
    flash[:success] = "Link has been #{action}."
    flash[:updated] = { url: @link.url, lgil: @interaction.lgil_code }
    redirect_to back_url
  end
end
