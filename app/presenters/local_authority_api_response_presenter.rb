class LocalAuthorityApiResponsePresenter
  def initialize(authority)
    @authority = authority
  end

  def present
    local_authority_json = {
      "local_authorities" => [
        present_local_authority(@authority),
      ],
    }
    if parent
      local_authority_json["local_authorities"] << present_local_authority(parent)
    end

    local_authority_json
  end

private

  def present_local_authority(local_authority)
    {
      "name" => local_authority.name,
      "homepage_url" => local_authority.homepage_url,
      "country_name" => local_authority.country_name,
      "tier" => local_authority.tier,
      "slug" => local_authority.slug,
      "snac" => local_authority.snac,
    }
  end

  def parent
    @parent ||= @authority.parent_local_authority
  end
end
