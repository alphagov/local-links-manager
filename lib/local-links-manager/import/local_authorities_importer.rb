require_relative 'import_comparer'
require_relative 'processor'
require_relative 'error_message_formatter'
require_relative 'errors'

module LocalLinksManager
  module Import
    class LocalAuthoritiesImporter
      def self.import_from_mapit
        new.authorities_from_mapit
      end

      def initialize(import_comparer = ImportComparer.new)
        @comparer = import_comparer
      end

      def local_authority_mapping
        {
          "COI" => unitary_tier_id,
          "CTY" => county_tier_id,
          "DIS" => district_tier_id,
          "LBO" => unitary_tier_id,
          "LGD" => unitary_tier_id,
          "MTD" => unitary_tier_id,
          "UTA" => unitary_tier_id,
        }
      end

      def authorities_from_mapit
        Processor.new(self).process
      end

      def each_item(&block)
        mapit_authorities.each(&block)
      end

      def import_item(item, _response, summariser)
        la = create_or_update_la(item, summariser)
        @comparer.add_source_record(la.slug)
      end

      def all_items_imported(response, _summariser)
        orphaned = connect_parents(mapit_authorities)
        response.errors << error_message_for_orphaned(orphaned) unless orphaned.empty?

        missing = @comparer.check_missing_records(LocalAuthority.all, &:slug)
        response.errors << error_message_for_missing(missing) unless missing.empty?
      end

      def self.local_authority_types
        new.local_authority_mapping.keys.join(',')
      end

      def import_name
        'LocalAuthorities Import'
      end

      def import_source_name
        'Objects from Mapit'
      end

    private

      def create_or_update_la(mapit_la, summariser)
        raise MissingIdentifierError, "Found empty code for local authority: #{mapit_la[:name]}" if mapit_la[:gss].blank? || mapit_la[:snac].blank?
        la = LocalAuthority.where(gss: mapit_la[:gss]).first_or_initialize
        existing_record = la.persisted?
        verb = existing_record ? "Updating" : "Creating"
        Rails.logger.info("#{verb} authority '#{mapit_la[:name]}' (gss #{mapit_la[:gss]})")

        la.name = mapit_la[:name]
        la.snac = mapit_la[:snac]
        la.slug = mapit_la[:slug]
        la.tier_id = mapit_la[:tier_id]
        la.save!
        if existing_record
          summariser.increment_updated_record_count
        else
          summariser.increment_created_record_count
        end
        la
      end

      def mapit_authorities
        @mapit_authorities ||=
          mapit_service_response
            .to_hash
            .values
            .map { |authority| local_authority_hash(authority) }
      end

      def mapit_service_response
        Services.mapit.areas_for_type(self.class.local_authority_types)
      end

      def local_authority_hash(parsed_authority)
        authority = {}
        authority[:name] = parsed_authority["name"]
        authority[:snac] = parsed_authority["codes"]["ons"]
        authority[:gss] = parsed_authority["codes"]["gss"]
        authority[:slug] = parsed_authority["codes"]["govuk_slug"]
        authority[:tier_id] = identify_tier_id(parsed_authority["type"])
        authority[:mapit_id] = parsed_authority["id"]
        authority[:parent_mapit_id] = parsed_authority["parent_area"]
        authority
      end

      def identify_tier_id(area_type)
        local_authority_mapping[area_type]
      end

      def district_tier_id
        @_district_tier_id ||= Tier.find_by(name: 'district').id
      end

      def unitary_tier_id
        @_unitary_tier_id ||= Tier.find_by(name: 'unitary').id
      end

      def county_tier_id
        @_county_tier_id ||= Tier.find_by(name: 'county').id
      end

      def connect_parents(mapit_las)
        orphaned = []
        child_mapit_las(mapit_las).each do |child_mapit_la|
          parent_mapit_la = find_parent_mapit_la(mapit_las, child_mapit_la)
          orphaned << child_mapit_la[:slug] && next if parent_mapit_la.nil?

          parent = LocalAuthority.find_by(slug: parent_mapit_la[:slug])
          orphaned << child_mapit_la[:slug] && next if parent.nil?

          update_child_with_parent(child_mapit_la, parent)
        end
        orphaned
      end

      def update_child_with_parent(child_mapit_la, parent)
        child = LocalAuthority.find_by(slug: child_mapit_la[:slug])
        child.parent_local_authority = parent
        child.save!
      end

      def child_mapit_las(mapit_las)
        mapit_las.select { |la| la[:parent_mapit_id] }
      end

      def find_parent_mapit_la(mapit_las, child_mapit_la)
        mapit_las.detect do |la|
          la[:mapit_id] == child_mapit_la[:parent_mapit_id]
        end
      end

      def error_message_for_orphaned(orphaned)
        ErrorMessageFormatter.new("LocalAuthority", "orphaned.", orphaned).message
      end

      def error_message_for_missing(missing)
        ErrorMessageFormatter.new("LocalAuthority", "no longer in the import source.", missing).message
      end
    end
  end
end
