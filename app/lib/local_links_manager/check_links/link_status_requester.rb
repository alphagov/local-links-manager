require "gds_api/link_checker_api"

module LocalLinksManager
  module CheckLinks
    class LinkStatusRequester
      delegate :url_helpers, to: "Rails.application.routes"

      def call
        ServiceInteraction.includes(:service)
          .where(services: { enabled: true })
          .find_each do |service|
            links = service.links.with_url.order(analytics: :asc)
            urls = links.select { |link| link.local_authority.active? }.map(&:url).uniq
            check_urls(urls) unless urls.empty?
        end

        check_urls homepage_urls
      end

      def check_authority_urls(authority_slug)
        check_urls urls_for_authority(authority_slug).uniq
      end

    private

      def urls_for_authority(authority_slug)
        local_authority = LocalAuthority.find_by(slug: authority_slug)
        local_authority.links.with_url.map(&:url) << local_authority.homepage_url
      end

      def homepage_urls
        LocalAuthority.active.map(&:homepage_url).sort
      end

      def check_urls(urls)
        link_checker_api.create_batch(
          urls,
          webhook_uri:,
          webhook_secret_token:,
        )
      end

      def webhook_uri
        Plek.find("local-links-manager") + url_helpers.link_checker_webhook_path
      end

      def webhook_secret_token
        Rails.application.credentials.link_checker_api_secret_token
      end

      def link_checker_api
        @link_checker_api ||= GdsApi::LinkCheckerApi.new(
          link_checker_api_url,
          bearer_token: ENV["LINK_CHECKER_API_BEARER_TOKEN"],
          timeout: 10,
        )
      end

      def link_checker_api_url
        Plek.find("link-checker-api")
      end
    end
  end
end
