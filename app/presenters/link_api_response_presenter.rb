class LinkApiResponsePresenter
  def initialize(authority, link)
    @authority = authority
    @link = link
  end

  def present
    if @link
      local_authority_details.merge(link_details)
    else
      local_authority_details
    end
  end

private

  def local_authority_details
    {
      "local_authority" => {
        "name" => @authority.name,
        "snac" => @authority.snac,
        "tier" => @authority.tier.name,
        "homepage_url" => @authority.homepage_url
      }
    }
  end

  def link_details
    {
      "local_interaction" => {
        "lgsl_code" => @link.service.lgsl_code,
        "lgil_code" => @link.interaction.lgil_code,
        "url" => @link.url
      }
    }
  end
end
