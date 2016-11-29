require 'local-links-manager/export/link_status_exporter'

class LinksController < ApplicationController
  before_action :load_dependencies
  before_action :retrieve_link, only: [:edit, :update, :destroy]
  before_action :set_back_url_before_post_request, only: [:edit, :update, :destroy]
  helper_method :back_url

  def index
    @links = presented_links
  end

  def edit
    if flash[:link_url]
      @link.url = flash[:link_url]
      @link.validate
    end
  end

  def update
    @link.url = link_url

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
    if @link.destroy
      redirect('deleted')
    else
      flash[:danger] = "Could not delete link."
      redirect_back
    end
  end

  def homepage_links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.homepage_links_status_csv
    send_data data, filename: "homepage_links_status.csv"
  end

  def links_status_csv
    data = LocalLinksManager::Export::LinkStatusExporter.links_status_csv
    send_data data, filename: "links_status.csv"
  end

private

  def load_dependencies
    @local_authority = LocalAuthorityPresenter.new(LocalAuthority.find_by(slug: params[:local_authority_slug]))
    @interaction = Interaction.find_by(slug: params[:interaction_slug])
    @service = Service.find_by(slug: params[:service_slug])
  end

  def retrieve_link
    @link = Link.retrieve(params)
  end

  def presented_links
    @_links ||= @local_authority.links.for_service(@service).map { |link| LinkPresenter.new(link, view_context: self) }
  end

  def set_back_url_before_post_request
    flash[:back] = back_url
  end

  def back_url
    flash[:back] ||
      request.env['HTTP_REFERER'] ||
      link_index_path(
        local_authority_slug: params[:local_authority_slug],
        service_slug: params[:service_slug]
      )
  end

  def link_url
    params[:link][:url].strip
  end

  def redirect_back
    flash[:link_url] = link_url
    redirect_to edit_link_path(@local_authority, @service, @interaction)
  end

  def redirect(action = 'saved')
    flash[:success] = "Link has been #{action}."
    flash[:updated] = { url: @link.url, lgil: @interaction.lgil_code }
    redirect_to back_url
  end
end
