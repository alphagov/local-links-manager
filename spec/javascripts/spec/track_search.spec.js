describe('A search tracker', function() {
  "use strict";

  var root = window,
    filterableTable,
    tableElement;

  beforeEach(function() {

    tableElement = $('<div data-module="track-search"\
           data-track-action="filterUsed"\
           data-track-label="filterUsed"\
           data-track-category="userInteraction:LLM">\
      <form>\
        <input type="text" class="js-filter-table-input">\
      </form>\
        <table>\
          <thead>\
              <tr class="table-header">\
              <th>\
                <form>\
                  <label for="search" class="rm">Search for a council here</label>\
                  <input id="search" type="text" class="form-control normal js-filter-table-input" placeholder="Search for a council here">\
                </form>\
              </th>\
            </tr>\
          </thead>\
          <tbody>\
            <tr class="first">\
              <td>\
                <a href="/first-link" class="js-open-on-submit">something</a>\
              </td>\
            </tr>\
            <tr class="second">\
              <td>\
                <a href="/second-link" class="js-open-on-submit">[another thing (^lovely$)]</a>\
              </td>\
            </tr>\
            <tr class="third">\
              <td>\
                <form>\
                  <input type="submit" value="Some other form" />\
                </form>\
                ~!@#$%^&*(){}[]`/=?+|-_;:\'",<.>\
              </td>\
            </tr>\
          </tbody>\
        </table>\
    </div>');

    $('body').append(tableElement);
    filterableTable = new GOVUKAdmin.Modules.TrackSearch();
  });

  afterEach(function() {
    tableElement.remove();
  });

  it('sends events based on input in filter search bar', function() {
    spyOn(GOVUKAdmin, 'trackEvent');
    filterableTable.start(tableElement);
    filterBy('another');
    expect(GOVUKAdmin.trackEvent).toHaveBeenCalledWith('filterUsed', 'filterUsed', 'another', 'userInteraction:LLM')
  });

  function filterBy(value) {
    tableElement.find('.js-filter-table-input').val(value).trigger('keyup');
  }

});
