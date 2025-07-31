require_relative "processor"
require_relative "errors"

module LocalLinksManager
  module Import
    class AnalyticsImporter
      def initialize(data = GoogleAnalytics::AnalyticsImportService.activity)
        @data = data
        @processed_ids = Set.new
      end

      def import_records
        @existing_ids_with_analytics = Set.new(Link.where.not(analytics: 0).pluck(:id))
        Processor.new(self).process
      end

      def each_item(&block)
        @data.each(&block)
      end

      def import_item(item, _response, summariser)
        link = Link.lookup_by_base_path(item[:base_path])

        if link
          link.update!(analytics: item[:clicks] || 0)
          summariser.increment_updated_record_count
          @processed_ids.add(link.id)
        else
          summariser.increment_missing_record_count
        end
      end

      def all_items_imported(response, _summariser)
        reset_count_on_links_not_in_analytics if response.successful?
      rescue StandardError => e
        response.errors << "Could not reset all old analytics counts due to: #{e}"
      end

      def import_name
        "Google Analytics Import"
      end

      def import_source_name
        "Downloaded Google Analytics stats"
      end

    private

      def reset_count_on_links_not_in_analytics
        links_to_reset = @existing_ids_with_analytics - @processed_ids

        links_to_reset.each do |id|
          Link.find(id).update!(analytics: 0)
        end
      end
    end
  end
end
