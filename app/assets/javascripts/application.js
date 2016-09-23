function setupFilterDropdown(rowSelector, placeholderText, doneCallback) {
  $( "#filter-dropdown" ).select2({
    placeholder: placeholderText,
    allowClear: true,
    theme: "bootstrap"
  }).on("select2:select", function (e) {
    var selectedItem = e.params.data.element.value.toString().split('-'),
      selectedType = selectedItem[0],
      selectedId = selectedItem[1];
    $(rowSelector).each(function(_idx, element) {
      var $element = $(element);
      if ($element.data(selectedType) !== undefined) {
        if ($element.data(selectedType).toString() === selectedId) {
          $element.show();
        } else {
          $element.hide();
        }
      }
    });
    doneCallback(selectedType, selectedId);
  }).on("select2:unselect", function (e) {
    $(rowSelector).each(function(idx, element) {
      $(element).show();
    });
  });
};
