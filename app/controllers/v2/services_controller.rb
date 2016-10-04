module V2
  class ServicesController < ApplicationController
    include SupportForSortOrderParam
    include SupportForLinkTypeParam

    def index
      @service = Service.find_by(slug: params[:slug])

      @local_authorities = LocalAuthority.
        provides_service(@service).
        with_broken_links_count(ServiceInteraction.arel_table[:service_id].eq(@service.id)).
        order(current_sort_order[:order_args])

      @links = Link.
        for_service(@service).
        with_correct_service_and_tier.
        includes(:interaction).
        enabled_links.
        order('links.local_authority_id asc, interactions.lgil_code asc').
        references(:service, :interaction).
        where(current_link_type_filter[:where_clauses]).
        all.
        group_by { |link| link.local_authority_id }

      @local_authorities_for_dropdown = @local_authorities.reorder(name: :asc).reject { |la| @links[la.id].blank? }
      @total_rows = @links.reduce(0) { |sum, (_service, links)| sum + links.size }
    end

    def self.default_sort_order
      @_default_sort_order ||= {
        'index' => {
          'alphabetical' => {
            description: 'A-Z (council name)',
            param: 'alphabetical',
            order_args: LocalAuthority.arel_table[:name].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: 'broken_links_count desc'
          },
        }.tap { |services_hash|
          services_hash.default = services_hash['broken-links']
        }
      }.tap { |sort_order_hash|
        sort_order_hash.default = sort_order_hash['index']
      }
    end

    def self.default_link_type_filters
      @_default_link_type_filters ||= {
        'index' => {
          'broken' => {
            description: 'Broken links',
            param: 'broken',
            where_clauses: Link.arel_table[:status].not_eq('200'),
            total_count_description: 'broken links',
          },
          'good' => {
            description: 'Good links',
            param: 'good',
            where_clauses: Link.arel_table[:status].eq('200'),
            total_count_description: 'good links',
          },
          'all' => {
            description: 'All links',
            param: 'all',
            where_clauses: '1=1',
            total_count_description: 'links',
          },
        }.tap { |index_hash|
          index_hash.default = index_hash['broken']
        }
      }.tap { |link_type_hash|
        link_type_hash.default = link_type_hash['index']
      }
    end
  end
end
