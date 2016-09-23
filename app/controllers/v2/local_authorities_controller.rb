module V2
  class LocalAuthoritiesController < ApplicationController
    include SupportForSortOrderParam

    def index
      @local_authority =
        LocalAuthorityPresenter.new(
          LocalAuthority.find_by(slug: params[:slug])
        )

      @services = Service.
        for_tier(@local_authority.tier).
        with_broken_links_count(Link.arel_table[:local_authority_id].eq(@local_authority.id)).
        order(current_sort_order[:order_args])

      @links = @local_authority.links.
        includes(:service, :interaction).
        enabled_links.
        order('services.lgsl_code asc, interactions.lgil_code asc').
        references(:service, :interaction).
        all.
        group_by { |link| link.service.id }
    end

    def self.default_sort_order
      @_default_sort_order ||= {
        'index' => {
          'default' => {
            description: 'Default (code)',
            param: 'default',
            order_args: Service.arel_table[:lgsl_code].asc
          },
          'alphabetical' => {
            description: 'A-Z',
            param: 'alphabetical',
            order_args: Service.arel_table[:label].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: 'broken_links_count desc'
          },
        }.tap { |local_authorities_hash|
          local_authorities_hash.default = local_authorities_hash['default']
        }
      }.tap { |sort_order_hash|
        sort_order_hash.default = sort_order_hash['index']
      }
    end

  end
end
