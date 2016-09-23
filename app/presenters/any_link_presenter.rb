class AnyLinkPresenter
  def self.for(link_container, *args)
    presenter_klass =
      case link_container
      when Link
        ForALink
      when LocalAuthority
        ForALocalAuthority
      end
    presenter_klass.new(link_container, *args)
  end

  class ForALink < SimpleDelegator
    include UrlStatusPresentation
    attr_reader :with_service_links_count

    def initialize(link, with_service: nil, with_service_links_count: 0, context:, local_authority: nil)
      super(link)
      @with_service = with_service
      @with_service_links_count = with_service_links_count
      @context = context
      @local_authority = local_authority
    end

    def edit_path
      @context.edit_local_authority_service_interaction_links_path(
        local_authority_slug: local_authority.slug,
        service_slug: service.slug,
        interaction_slug: interaction.slug
      )
    end

    def local_authority
      @local_authority.nil? ? super() : @local_authority
    end

    def interaction_label
      interaction.label
    end

    def with_service_lgsl_code
      @with_service.try :lgsl_code
    end

    def with_service_label
      @with_service.try :label
    end

    def with_service_slug
      @with_service.try :slug
    end
  end

  class ForALocalAuthority < SimpleDelegator
    include UrlStatusPresentation

    def initialize(local_authority, context:)
      super(local_authority)
      @context = context
    end

    def url
      homepage_url
    end

    def edit_path
      @context.edit_local_authority_path(slug: slug)
    end

    def interaction_label
      'Homepage'
    end

    def with_service_lgsl_code; ''; end

    def with_service_label; nil; end

    def with_service_slug; nil; end

    def with_service_links_count; 1; end
  end
end
