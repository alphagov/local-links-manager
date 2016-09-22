module V2
  class HomeController < ApplicationController
    def broken_links
      @local_authorities = LocalAuthority.
        order(name: :desc)

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
      @local_authorities = LocalAuthority.order(name: :desc)
    end

    def services
      @services =
        Service.order(lgsl_code: :desc)
    end
  end
end
