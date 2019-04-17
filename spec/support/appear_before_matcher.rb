module SortOrderMatchers
  class AppearBeforeMatcher < Capybara::RSpecMatchers::Matchers
    def initialize(*later_content)
      @later_content = later_content[0]
    end

    def matches?(earlier_content)
      @earlier_content = earlier_content
      page.body.index(earlier_content) < page.body.index(@later_content)
    end

    def description
      "appear in the rendered page before #{@later_content}"
    end

    def failure_message
      "Expected to find #{@earlier_content} in the page before #{@later_content} but it isn't"
    end

    def page
      Capybara.current_session
    end
  end

  def appear_before(later_content)
    AppearBeforeMatcher.new(later_content)
  end
end

RSpec.configure do |config|
  config.include SortOrderMatchers, type: :feature
end
