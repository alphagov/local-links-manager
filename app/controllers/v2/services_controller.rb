module V2
  class ServicesController < ApplicationController
    include SupportForSortOrderParam

    def index
      @service = Service.find_by(slug: params[:slug])

      @local_authorities = LocalAuthority.
        provides_service(@service).
        with_broken_links_count(ServiceInteraction.arel_table[:service_id].eq(@service.id)).
        order(current_sort_order[:order_args])

      @links = Link.
        for_service(@service).
        includes(:interaction).
        enabled_links.
        order('links.local_authority_id asc, interactions.lgil_code asc').
        references(:service, :interaction).
        all.
        group_by { |link| link.local_authority_id }
    end

    def self.default_sort_order
      @_default_sort_order ||= {
        'index' => {
          'default' => {
            description: 'Default (A-Z)',
            param: 'default',
            order_args: LocalAuthority.arel_table[:name].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: 'broken_links_count desc'
          },
        }.tap { |services_hash|
          services_hash.default = services_hash['default']
        }
      }.tap { |sort_order_hash|
        sort_order_hash.default = sort_order_hash['index']
      }
    end

  end
end
