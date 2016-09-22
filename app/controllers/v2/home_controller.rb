module V2
  class HomeController < ApplicationController
    def broken_links
      @local_authorities = local_authorities_with_broken_links_count.
        order(current_sort_order[:order_args]).
        where(Arel::Table.new(:counts)['broken_links_count'].gt(0))

      links_by_authority = Link.
          includes(:service, :interaction).
          enabled_links.
          broken.
          order('services.lgsl_code asc, interactions.lgil_code asc').
          references(:service, :interaction).
          all.
          group_by { |link| link.local_authority_id }

      @links = Hash[
        links_by_authority.
          map { |la, links| [la, links.group_by { |link| link.service }] }
      ]
    end

    def local_authorities
      @local_authorities = local_authorities_with_broken_links_count.order(current_sort_order[:order_args])
    end

    def local_authorities_with_broken_links_count
      # this seems a tad complex, but then we are using arel so...

      # 1. construct inner query to count links grouped by service_id
      #    we do this in activerecord and then grab the arel version of it so we
      #    can...
      counts = Link.
        enabled_links.
        broken.
        group(Link.arel_table[:local_authority_id]).
        select(Link.arel_table[:local_authority_id], Link.arel_table[:id].count.as('broken_links_count')).
        arel
      counts_table = Arel::Table.new(:counts)

      # 2. ...join that arel query to the services table on the service_id
      counts_join = LocalAuthority.
        arel_table.
        join(counts.as('counts')).
        on(LocalAuthority.arel_table['id'].eq(counts_table['local_authority_id'])).
        join_sources

      # 3.  finally, drop back to activerecord to do the query and make sure
      #     to select the count in the query
      LocalAuthority.
        select([LocalAuthority.arel_table[Arel.star], counts_table['broken_links_count']]).
        joins(counts_join)
    end

    def services
      @services =
        services_with_broken_links_count.order(current_sort_order[:order_args])
    end

    def services_with_broken_links_count
      # this seems a tad complex, but then we are using arel so...

      # 1. construct inner query to count links grouped by service_id
      #    we do this in activerecord and then grab the arel version of it so we
      #    can...
      counts = Link.
        enabled_links.
        broken.
        joins(:service_interaction).
        group(ServiceInteraction.arel_table[:service_id]).
        select(ServiceInteraction.arel_table[:service_id], Link.arel_table[:id].count.as('broken_links_count')).
        arel
      counts_table = Arel::Table.new(:counts)

      # 2. ...join that arel query to the services table on the service_id
      counts_join = Service.
        arel_table.
        join(counts.as('counts')).
        on(Service.arel_table['id'].eq(counts_table['service_id'])).
        join_sources

      # 3.  finally, drop back to activerecord to do the query and make sure
      #     to select the count in the query
      Service.
        enabled.
        select([Service.arel_table[Arel.star], counts_table['broken_links_count']]).
        joins(counts_join)
    end

    def self.default_sort_order
      @_default_sort_order ||= {
        'services' => {
          'default' => {
            description: 'Default (code)',
            param: 'default',
            order_args: Service.arel_table['lgsl_code'].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: Arel::Table.new(:counts)['broken_links_count'].desc
          },
          'alphabetical' => {
            description: 'A-Z',
            param: 'alphabetical',
            order_args: Service.arel_table['label'].asc
          },
        }.tap { |services_hash|
          services_hash.default = services_hash['default']
        },
        'local_authorities' => {
          'default' => {
            description: 'Default (A-Z)',
            param: 'default',
            order_args: LocalAuthority.arel_table[:name].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: Arel::Table.new(:counts)['broken_links_count'].desc
          },
        }.tap { |local_authorities_hash|
          local_authorities_hash.default = local_authorities_hash['default']
        },
        'broken_links' => {
          'default' => {
            description: 'Default (A-Z)',
            param: 'default',
            order_args: LocalAuthority.arel_table[:name].asc
          },
          'broken-links' => {
            description: 'Number of broken links',
            param: 'broken-links',
            order_args: Arel::Table.new(:counts)['broken_links_count'].desc
          },
        }.tap { |broken_links_hash|
          broken_links_hash.default = broken_links_hash['default']
        }
      }
    end

    def current_sort_order
      self.class.default_sort_order[action_name][params.fetch(:sort_order, 'default')]
    end
    helper_method :current_sort_order

    def all_sort_order_options
      self.class.default_sort_order[action_name].values
    end
    helper_method :all_sort_order_options
  end
end
