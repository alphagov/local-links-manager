class LinkApiResponsePresenter
  def initialize(given_authority, link)
    @given_authority = given_authority
    @link = link
  end

  def present
    local_authority_details.merge(link_details)
  end

private

  attr_reader :given_authority, :link

  def authority
    link&.local_authority || given_authority
  end

  def local_authority_details
    { "local_authority" => LocalAuthorityHashPresenter.new(authority).to_h }
  end

  def link_details
    return {} unless link

    {
      "local_interaction" => {
        "lgsl_code" => link.service.lgsl_code,
        "lgil_code" => link.interaction.lgil_code,
        "url" => link.url,
        "status" => link.status,
      },
    }
  end
end
