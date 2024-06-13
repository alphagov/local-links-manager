class ServicesController < ApplicationController
  include LinkFilterHelper
  include LinkImporterUtils

  before_action :set_service, except: :index

  def index
    @services = Service.enabled.order(broken_link_count: :desc)
    raise "Missing Data" if @services.empty?

    @breadcrumbs = index_breadcrumbs
  end

  def show
    set_filter_var
    @link_filter = params[:filter]
    @links = links_for_service
    @breadcrumbs = service_breadcrumbs(@service)
  end

  def download_links_form
    @breadcrumbs = service_breadcrumbs(@service) + [{ title: "Download Links", url: download_links_form_service_path(@service) }]
  end

  def download_links_csv
    service_name = @service.label.parameterize.underscore
    statuses = params[:links_status_checkbox] & %w[ok broken caution missing pending]
    not_provided_by_authority = params[:not_provided_by_authority_checkbox] & %w[not_provided_by_authority]
    data = LocalLinksManager::Export::ServiceLinksExporter.new.export_links(@service.id, statuses, not_provided_by_authority)
    send_data data, filename: "#{service_name}_links.csv"
  end

  def upload_links_form
    @breadcrumbs = service_breadcrumbs(@service) + [{ title: "Upload Links", url: upload_links_form_service_path(@service) }]
  end

  def upload_links_csv
    attempt_import(:service, @service)
    redirect_to service_path(@service)
  end

private

  def set_service
    @service = Service.find_by!(slug: params[:service_slug])
  end

  def links_for_service
    @links_for_service ||= filtered_links(@service.links)
      .includes(%i[interaction local_authority service_interaction])
      .where(local_authority: @service.local_authorities)
      .all
  end

  def index_breadcrumbs
    [{ title: "Home", url: root_path }, { title: "Services", url: services_path }]
  end

  def service_breadcrumbs(service)
    index_breadcrumbs + [{ title: service.label, url: service_path(service) }]
  end
end
