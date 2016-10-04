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
        for_tier(@local_authority.tier).
        with_broken_links_count(Link.arel_table[:local_authority_id].eq(@local_authority.id)).
        order(current_sort_order[:order_args])

      @links = @local_authority.links.
        includes(:service, :interaction).
        with_correct_service_and_tier.
        enabled_links.
        order('services.lgsl_code asc, interactions.lgil_code asc').
        references(:service, :interaction).
        where(current_link_type_filter[:where_clauses]).
        all.
        group_by { |link| link.service.id }

      @services_for_dropdown = @services.reorder(label: :asc).reject { |s| @links[s.id].blank? }
      @total_rows = @links.reduce(0) { |sum, (_service, links)| sum + links.size }
    end

    def with_service
      @local_authority =
        LocalAuthorityPresenter.new(
          LocalAuthority.find_by(slug: params[:local_authority_slug])
        )

      @service = Service.find_by(slug: params[:service_slug])

      @links = @local_authority.links.
        for_service(@service).
        includes(:interaction).
        enabled_links.
        order('links.local_authority_id asc, interactions.lgil_code asc').
        references(:service, :interaction).
        where(current_link_type_filter[:where_clauses]).
        all

      @interactions_for_dropdown = @links.map(&:interaction).sort_by(&:label)
      @total_rows = @links.count
      @total_broken_rows = @links.broken.count
    end

    def self.default_sort_order
      @_default_sort_order ||= {
        'index' => {
          'code' => {
            description: 'Service code',
            param: 'code',
            order_args: Service.arel_table[:lgsl_code].asc
          },
          'alphabetical' => {
            description: 'A-Z (service name)',
            param: 'alphabetical',
            order_args: Service.arel_table[:label].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: 'broken_links_count desc'
          },
        }.tap { |local_authorities_hash|
          local_authorities_hash.default = local_authorities_hash['broken-links']
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
            where_clauses: Link.arel_table[:status].not_eq('200')
          },
          'good' => {
            description: 'Good links',
            param: 'good',
            where_clauses: Link.arel_table[:status].eq('200')
          },
          'all' => {
            description: 'All links',
            param: 'all',
            where_clauses: '1=1'
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
