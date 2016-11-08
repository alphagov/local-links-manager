module SupportForLinkTypeParam
  extend ActiveSupport::Concern

  included do
    def current_link_type_filter
      self.class.default_link_type_filters[action_name][params['link_type']]
    end
    helper_method :current_link_type_filter

    def all_link_type_filters
      self.class.default_link_type_filters[action_name].values
    end
    helper_method :all_link_type_filters
  end
end
