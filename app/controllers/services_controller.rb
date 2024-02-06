class ServicesController < ApplicationController
  include LinkFilterHelper
  include LinkImporterUtils

  def index
    @services = Service.enabled.order(broken_link_count: :desc)
    raise "Missing Data" if @services.empty?

    @breadcrumbs = index_breadcrumbs
  end

  def show
    @service = Service.find_by!(slug: params[:service_slug])
    @local_authorities = @service.local_authorities.order(name: :asc)
    @link_count = links_for_service.count
    @link_filter = params[:filter]
    @links = links_for_service.group_by(&:local_authority_id)
    @breadcrumbs = service_breadcrumbs(@service)
  end

  def download_links_csv
    @service = Service.find_by!(slug: params[:service_slug])
    service_name = @service.label.parameterize.underscore
    data = LocalLinksManager::Export::ServiceLinksExporter.new.export_links(@service.id, params)
    send_data data, filename: "#{service_name}_links.csv"
  end

  def upload_links_csv
    service = Service.find_by!(slug: params[:service_slug])
    attempt_import(:service, service)
    redirect_to service_path(service)
  end

private

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
