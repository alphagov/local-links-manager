module V2
  class ServicesController < ApplicationController
    include SupportForSortOrderParam
    include SupportForLinkTypeParam

    def index
      @service = Service.find_by(slug: params[:slug])

      @local_authorities = LocalAuthority.
        # TODO - this doesn't seem to be applied everywhere so we're not
        # getting the right links for a tier in all situations - investigate
        # provides_service(@service).
        with_broken_links_count(ServiceInteraction.arel_table[:service_id].eq(@service.id)).
        order(current_sort_order[:order_args])

      @links = Link.
        for_service(@service).
        includes(:interaction).
        enabled_links.
        order('links.local_authority_id asc, interactions.lgil_code asc').
        references(:service, :interaction).
        where(current_link_type_filter[:where_clauses]).
        all.
        group_by { |link| link.local_authority_id }

      @local_authorities_for_dropdown = @local_authorities.reorder(name: :asc).reject { |la| @links[la.id].blank? }
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

    def self.default_link_type_filters
      @_default_link_type_filters ||= {
        'index' => {
          'all' => {
            description: 'All links',
            param: 'all',
            where_clauses: '1=1'
          },
          'good' => {
            description: 'Good links',
            param: 'good',
            where_clauses: Link.arel_table[:status].eq('200')
          },
          'broken' => {
            description: 'Broken links',
            param: 'broken',
            where_clauses: Link.arel_table[:status].not_eq('200')
          }
        }.tap { |index_hash|
          index_hash.default = index_hash['all']
        }
      }.tap { |link_type_hash|
        link_type_hash.default = link_type_hash['index']
      }
    end
  end
end
