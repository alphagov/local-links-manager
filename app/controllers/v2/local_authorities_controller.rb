module V2
  class LocalAuthoritiesController < ApplicationController
    include SupportForSortOrderParam
    include SupportForLinkTypeParam

    def index
      @local_authority =
        LocalAuthorityPresenter.new(
          LocalAuthority.find_by(slug: params[:slug])
        )

      @services = Service.
        # TODO - this doesn't seem to be applied everywhere so we're not
        # getting the right links for a tier in all situations - investigate
        # for_tier(@local_authority.tier).
        with_broken_links_count(Link.arel_table[:local_authority_id].eq(@local_authority.id)).
        order(current_sort_order[:order_args])

      @links = @local_authority.links.
        includes(:service, :interaction).
        enabled_links.
        order('services.lgsl_code asc, interactions.lgil_code asc').
        references(:service, :interaction).
        where(current_link_type_filter[:where_clauses]).
        all.
        group_by { |link| link.service.id }

      @services_for_dropdown = @services.reorder(label: :asc).reject { |s| @links[s.id].blank? }
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
