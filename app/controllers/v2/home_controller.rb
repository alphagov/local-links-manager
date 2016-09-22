module V2
  class HomeController < ApplicationController
    def broken_links
      @local_authorities = LocalAuthority.
        order(current_sort_order[:order_args])

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
      @local_authorities = LocalAuthority.order(current_sort_order[:order_args])
    end

    def services
      @services =
        Service.order(current_sort_order[:order_args])
    end

    def self.default_sort_order
      @_default_sort_order ||= {
        'services' => {
          'default' => {
            description: 'Default (code)',
            param: 'default',
            order_args: Service.arel_table['lgsl_code'].asc
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
        }.tap { |local_authorities_hash|
          local_authorities_hash.default = local_authorities_hash['default']
        },
        'broken_links' => {
          'default' => {
            description: 'Default (A-Z)',
            param: 'default',
            order_args: LocalAuthority.arel_table[:name].asc
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
