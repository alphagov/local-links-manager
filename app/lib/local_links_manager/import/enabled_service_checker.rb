require_relative "csv_downloader"
require_relative "response"

module LocalLinksManager
  module Import
    class EnabledServiceChecker
      CSV_URL = "https://raw.githubusercontent.com/alphagov/publisher/master/data/local_services.csv".freeze

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL))
        @csv_downloader = csv_downloader
      end

      def import_name
        "Enabled Service Checker"
      end

      def import_source_name
        "Downloaded CSV rows"
      end

      def each_item(&block)
        @csv_downloader.each_row(&block)
      end

      def import_item(item, _response, _summariser)
        supported_lgsl_codes.add(item["LGSL"])
      end

      def supported_lgsl_codes
        @supported_lgsl_codes ||= Set.new
      end

      def all_items_imported(response, summariser)
        Service.all.find_each { |service| set_enabled_state(service, summariser) }

        missing = check_for_missing_services(summariser)

        response.errors << error_message(missing) unless missing.empty?
        summariser.add_summary summarise_services_enable
      end

      def enable_services
        Processor.new(self).process
      end

    private

      def set_enabled_state(service, summariser)
        enabled = @supported_lgsl_codes.include? service.lgsl_code.to_s
        service.enabled = enabled
        Rails.logger.info("'#{service.lgsl_code}' enabled = #{enabled}")
        service.save!
        summariser.increment_updated_record_count
      end

      def check_for_missing_services(summariser)
        missing = []
        supported_lgsl_codes.each do |lgsl|
          if Service.find_by(lgsl_code: lgsl).nil?
            missing << lgsl
            summariser.increment_missing_record_count
          end
        end
        missing
      end

      def error_message(missing)
        suffix = "not present."
        if missing.count == 1
          "1 Service is #{suffix}\n#{list_missing(missing)}\n"
        else
          "#{missing.count} Services are #{suffix}\n#{list_missing(missing)}\n"
        end
      end

      def list_missing(missing)
        missing.to_a.sort.join("\n")
      end

      def summarise_services_enable
        total_services_count = Service.all.count
        enabled_services_count = Service.where(enabled: true).count
        supported_lgsl_codes_count = supported_lgsl_codes.count

        result = "Enabled #{enabled_services_count} of #{total_services_count} services\n"

        unless supported_lgsl_codes_count == enabled_services_count
          result += "Could not enable all services in the CSV "\
            "(#{enabled_services_count} enabled, but there are "\
            "#{supported_lgsl_codes_count} services in the list)\n"
        end
        result
      end
    end
  end
end
