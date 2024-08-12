class LocalAuthoritiesController < ApplicationController
  include LinkFilterHelper
  include LinkImporterUtils

  before_action :set_authority, except: %i[index bad_homepage_url_and_status_csv]

  def index
    Rails.logger.info(params)

    @authorities = if params[:filter]&.include?("only_active")
                     LocalAuthority.active.order(broken_link_count: :desc)
                   else
                     LocalAuthority.order(broken_link_count: :desc)
                   end

    @authorities = @authorities.where.not(status: "ok") if params[:filter]&.include?("only_homepage_problems")

    @breadcrumbs = index_breadcrumbs
  end

  def show
    set_filter_var
    @link_filter = params[:filter]
    @links = links_for_authority.includes(:service).order("services.label")
    @breadcrumbs = local_authority_breadcrumbs(@authority)
  end

  def edit_url
    @breadcrumbs = local_authority_breadcrumbs(@authority) + [{ title: "Edit URL", url: edit_url_local_authority_path(@authority) }]
  end

  def update
    @authority.update!(homepage_url: params[:homepage_url])

    redirect_to local_authority_path(@authority)
  end

  def download_links_form
    @breadcrumbs = local_authority_breadcrumbs(@authority) + [{ title: "Download Links", url: download_links_form_local_authority_path(@authority) }]
  end

  def download_links_csv
    authority_name = @authority.name.parameterize.underscore
    statuses = params[:links_status_checkbox] & %w[ok broken caution missing pending]
    not_provided_by_authority = params[:not_provided_by_authority_checkbox] & %w[not_provided_by_authority]
    data = LocalLinksManager::Export::LocalAuthorityLinksExporter.new.export_links(@authority.id, statuses, not_provided_by_authority)
    send_data data, filename: "#{authority_name}_links.csv"
  end

  def upload_links_form
    @breadcrumbs = local_authority_breadcrumbs(@authority) + [{ title: "Upload Links", url: upload_links_form_local_authority_path(@authority) }]
  end

  def upload_links_csv
    redirect_to local_authority_path(@authority) if attempt_import(:local_authority, @authority)

    redirect_to(upload_links_form_local_authority_path(@authority))
  end

  def bad_homepage_url_and_status_csv
    data = LocalLinksManager::Export::BadLinksUrlAndStatusExporter.local_authority_bad_homepage_url_and_status_csv
    send_data data, filename: "bad_homepage_url_status.csv"
  end

private

  def set_authority
    @authority = LocalAuthority.find_by!(slug: params[:local_authority_slug])
  end

  def index_breadcrumbs
    [{ title: "Home", url: root_path }, { title: "Councils", url: local_authorities_path(filter: %w[only_active]) }]
  end

  def local_authority_breadcrumbs(local_authority)
    index_breadcrumbs + [{ title: local_authority.name, url: local_authority_path(local_authority) }]
  end

  def links_for_authority
    @links_for_authority ||= filtered_links(@authority.provided_service_links)
      .includes(%i[service interaction])
      .all
  end
end
