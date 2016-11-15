require_relative 'csv_downloader'
require_relative 'processor'
require_relative 'errors'

module LocalLinksManager
  module Import
    class ServicesTierImporter
      CSV_URL = "https://raw.githubusercontent.com/alphagov/publisher/master/data/local_services.csv".freeze
      FIELD_NAME_CONVERSIONS = {
        'LGSL' => :lgsl_code,
        'Providing Tier' => :tier,
      }.freeze

      def self.import
        new.import_tiers
      end

      def initialize(csv_downloader = CsvDownloader.new(CSV_URL, header_conversions: FIELD_NAME_CONVERSIONS))
        @csv_downloader = csv_downloader
      end

      def import_tiers
        Processor.new(self).process
      end

      def import_name
        'ServiceTier import'
      end

      def import_source_name
        'Downloaded CSV rows'
      end

      def each_item(&block)
        @csv_downloader.each_row(&block)
      end

      def import_item(item, response, summariser)
        raise MissingIdentifierError if item[:lgsl_code].blank?
        service = Service.find_by(lgsl_code: item[:lgsl_code])
        raise MissingRecordError, "LGSL #{item[:lgsl_code]} is missing" if service.nil?
        Rails.logger.info("Updating service '#{service.label}' (lgsl #{service.lgsl_code})")

        if item[:tier].blank?
          response.errors << "LGSL #{item[:lgsl_code]} is missing a tier"
          summariser.increment_ignored_items_count
        elsif not update_tier(service, item[:tier])
          response.errors << "LGSL #{item[:lgsl_code]} has incorrect tier name"
          summariser.increment_ignored_items_count
        else
          summariser.increment_updated_record_count
        end
      end

      def update_tier(service, tier_name)
        case tier_name
        when 'district/unitary'
          ServiceTier.create(service: service, tier: Tier.district)
          ServiceTier.create(service: service, tier: Tier.unitary)
        when 'county/unitary'
          ServiceTier.create(service: service, tier: Tier.county)
          ServiceTier.create(service: service, tier: Tier.unitary)
        when 'all'
          ServiceTier.create(service: service, tier: Tier.county)
          ServiceTier.create(service: service, tier: Tier.unitary)
          ServiceTier.create(service: service, tier: Tier.district)
        else
          false
        end
      end
    end
  end
end
