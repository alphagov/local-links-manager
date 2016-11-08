module SupportForSortOrderParam
  extend ActiveSupport::Concern

  included do
    def current_sort_order
      self.class.default_sort_order[action_name][params[:sort_order]]
    end
    helper_method :current_sort_order

    def all_sort_order_options
      self.class.default_sort_order[action_name].values
    end
    helper_method :all_sort_order_options
  end
end
