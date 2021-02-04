class ServicesController < ApplicationController
  include LinkFilterHelper

  def index
    @services = Service.enabled.order(broken_link_count: :desc)
    raise "Missing Data" if @services.empty?
  end

  def show
    @service = Service.find_by!(slug: params[:service_slug])
    @local_authorities = @service.local_authority_links.order(name: :asc)
    @link_count = links_for_service.count
    @link_filter = params[:filter]
    @links = links_for_service.group_by(&:local_authority_id)
  end

private

  def links_for_service
    @links_for_service ||= filtered_links(@service.links)
      .includes(%i[service interaction local_authority])
      .where(local_authority: @service.local_authority_links)
      .all
  end
end
