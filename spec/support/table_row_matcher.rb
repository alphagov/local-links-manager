module TableRowMatchers
  class SimpleTableRowMatcher < Capybara::RSpecMatchers::Matchers
    def initialize(*row_of_text)
      @row_of_text = row_of_text
    end

    def matches?(actual)
      rows_of_text_in_table(actual).include? @row_of_text
    end

    def does_not_match?(actual)
      !rows_of_text_in_table(actual).include? @row_of_text
    end

    def description
      "have a table row with cells #{@row_of_text.inspect}"
    end

    def failure_message
      "Expected to find a table row with cells #{@row_of_text.inspect} in #{rows_of_text_in_table.inspect} but we didn't!"
    end

    def failure_message_when_negated
      "Expected to not find a table row cells #{@row_of_text.inspect} in #{rows_of_text_in_table.inspect} but we did!"
    end

    def rows_in_table(actual = nil)
      if actual.nil?
        @rows_in_table
      else
        @rows_in_table = actual.all('tr')
      end
    end

    def rows_of_text_in_table(actual = nil)
      if actual.nil?
        @rows_of_text_in_table
      else
        @rows_of_text_in_table ||= rows_in_table(actual).map { |row| row.all('th, td').map(&:text) }
      end
    end
  end

  def have_table_row(*row_of_text)
    SimpleTableRowMatcher.new(*row_of_text)
  end
end

RSpec.configure do |config|
  config.include TableRowMatchers, type: :feature
end
