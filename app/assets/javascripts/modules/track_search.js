(function(Modules) {
  "use strict";

  Modules.TrackSearch = function() {
    var that = this;

    that.start = function(container) {

      var filterSearchInput = container.find('.js-filter-table-input');
      container.on('keyup', '.js-filter-table-input', trackSearch);

      function trackSearch() {
        var action = container.data('track-action'),
          label = $.trim(filterSearchInput.val()),
          category = container.data('track-category'),
          value = container.data('track-value');

        GOVUKAdmin.trackEvent(action, label, value, category);
      };
    }
  };

})(window.GOVUKAdmin.Modules);
