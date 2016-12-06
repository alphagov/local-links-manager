class LinkPresenter < SimpleDelegator
  include UrlStatusPresentation
  attr_reader :view_context

  def initialize(link, view_context:)
    @view_context = view_context
    super(link)
  end
end
