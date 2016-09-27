module V2
  class HomeController < ApplicationController
    include SupportForSortOrderParam

    def broken_links
      @local_authorities = LocalAuthority.
        with_broken_links_count.
        order(current_sort_order[:order_args]).
        where(Arel::Table.new(:counts)['broken_links_count'].gt(0))

      links_by_authority = Link.
          includes(:service, :interaction).
          with_correct_service_and_tier.
          enabled_links.
          broken.
          order('services.lgsl_code asc, interactions.lgil_code asc').
          references(:service, :interaction).
          all.
          group_by { |link| link.local_authority_id }

      @local_authorities_for_dropdown = @local_authorities.reorder(name: :asc).reject { |la| links_by_authority[la.id].blank? }
      @services_for_dropdown = links_by_authority.flat_map { |_la, links| links.map &:service }.uniq.sort_by { |s| s.label }

      @links = Hash[
        links_by_authority.
          map { |la, links| [la, links.group_by { |link| link.service }] }
      ]
      @total_rows = @links.reduce(0) do |sum, (_la, links_by_service)|
        sum + links_by_service.reduce(0) do |ssum, (_service, links)|
          ssum + links.size
        end
      end
    end

    def local_authorities
      @local_authorities = LocalAuthority.with_broken_links_count.order(current_sort_order[:order_args])
      @local_authorities_for_dropdown = @local_authorities.reorder(name: :asc)
      @total_rows = @local_authorities.count("id")
    end

    def services
      @services = Service.with_broken_links_count.order(current_sort_order[:order_args])
      @services_for_dropdown = @services.reorder(label: :asc)
      @total_rows = @services.count("id")
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
            order_args: 'broken_links_count desc'
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
            order_args: 'broken_links_count desc'
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
            order_args: 'broken_links_count desc'
          },
        }.tap { |broken_links_hash|
          broken_links_hash.default = broken_links_hash['default']
        }
      }
    end
  end
end
