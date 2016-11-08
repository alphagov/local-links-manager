function setupFilterDropdown(rowSelector, placeholderText, filterCallback, unfilterCallback) {
  function setTotalRows(countFunc) {
    var $totalRows = $('[data-total-rows]')
    if ($totalRows.length > 0) {
      var count = countFunc($totalRows);
      $totalRows.find('.big-number').html(count);
    }
  }
  function itemSelected(event_data) {
    if (event_data['url'] !== true) {
      var selectedItem = event_data.id.toString().split(':'),
        selectedType = selectedItem[0],
        selectedId = selectedItem[1];
      $(rowSelector+"[data-row][data-"+selectedType+"][data-"+selectedType+"='"+selectedId+"']").show();
      $(rowSelector+"[data-row][data-"+selectedType+"]:not([data-"+selectedType+"='"+selectedId+"'])").hide();
      filterCallback(selectedType, selectedId);
    } else {
      var url = event_data.text;
      $(rowSelector + "[data-row][data-url][data-url^='"+url+"']:hidden").show();
      $(rowSelector + "[data-row][data-url]:not([data-url^='"+url+"']):visible").hide();
      filterCallback('url', url);
    }
    setTotalRows(function(_$totalRows) { return $(rowSelector+'[data-row]:visible').length; });
  }
  var filterDropdown = $( "#filter-dropdown" ).select2({
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
  })
  filterDropdown.on("select2:select", function (e) {
    itemSelected(e.params.data);
  }).on("select2:unselect", function (e) {
    $(rowSelector+":hidden").show();
    setTotalRows(function($totalRows) { return $totalRows.data('totalRows'); });
    unfilterCallback();
  });
  $(window).bind("pageshow", function() {
    if (filterDropdown.val() !== "") {
      var option = filterDropdown.find("option[value='"+filterDropdown.val()+"']"),
      data = {
        id: option.val(),
        text: option.text,
        url: option.val().match(/^https?:\/\//)
      }
      itemSelected(data);
    }
  });
};
function setupLinkTypeFilterRadioButtons() {
  $( "input[name=link_type]" ).on("change", function (e) {
    window.location.href = $(e.target).closest('a').attr('href');
  })
};
