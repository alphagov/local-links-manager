function setupFilterDropdown(rowSelector, placeholderText, doneCallback) {
  $( "#filter-dropdown" ).select2({
    placeholder: placeholderText,
    allowClear: true,
    theme: "bootstrap",
    tags: true,
    createTag: function(params) {
      var term = params.term;
      if (term.match(/^https?:\/\//)) {
        return {
          id: term,
          text: term,
          url: true
        };
      } else {
        $(rowSelector + "[data-url]:hidden").show();
        return null;
      }
    }
  }).on("select2:select", function (e) {
    if (e.params.data['url'] !== true) {
      var selectedItem = e.params.data.element.value.toString().split(':'),
        selectedType = selectedItem[0],
        selectedId = selectedItem[1];
      $(rowSelector+"[data-"+selectedType+"][data-"+selectedType+"='"+selectedId+"']").show();
      $(rowSelector+"[data-"+selectedType+"]:not([data-"+selectedType+"='"+selectedId+"'])").hide();
      doneCallback(selectedType, selectedId);
    } else {
      var url = e.params.data.text;
      $(rowSelector + "[data-url][data-url^='"+url+"']:hidden").show();
      $(rowSelector + "[data-url]:not([data-url^='"+url+"']):visible").hide();
      doneCallback('url', url);
    }
  }).on("select2:unselect", function (e) {
    $(rowSelector+":hidden").show();
  });
};
function setupLinkTypeFilterRadioButtons() {
  $( "input[name=link_type]" ).on("change", function (e) {
    window.location.href = $(e.target).parent('a').attr('href');
  })
};
