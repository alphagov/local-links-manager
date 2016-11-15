require 'rails_helper'
require 'local-links-manager/import/local_authorities_importer'
require 'gds_api/test_helpers/mapit'

describe LocalLinksManager::Import::LocalAuthoritiesImporter do
  include GdsApi::TestHelpers::Mapit

  def fixture_file(file)
    File.expand_path("fixtures/" + file, File.dirname(__FILE__))
  end

  describe 'import of local authorities from MapIt' do
    let(:source_mapit_data) { File.read(fixture_file('mapit.json')) }
    let(:mapit_data) { JSON.parse(source_mapit_data) }

    describe 'importing local authorities without connecting parents' do
      context 'successful mapit import' do
        before(:each) do
          mapit_has_areas(described_class.local_authority_types, mapit_data)
        end

        it 'reports a successful import' do
          expect(described_class.import_from_mapit).to be_successful
        end

        it 'imports MapIt formatted json' do
          described_class.import_from_mapit
          expect(LocalAuthority.count).to eq(8)

          la = LocalAuthority.find_by(gss: 'S12000033')

          expect(la.name).to eq("Aberdeen City Council")
          expect(la.snac).to eq("00QA")
          expect(la.tier.name).to eq("unitary")
          expect(la.slug).to eq("aberdeen-city-council")
        end

        it 'updates name, SNAC, slug and tier fields' do
          described_class.import_from_mapit
          updated_name_ons_slug_and_tier = {
            "9999": {
              "parent_area": nil,
              "generation_high": 1,
              "all_names": {},
              "id": 9999,
              "codes": {
                "ons": "XXXX",
                "gss": "S12000033",
                "unit_id": "30421",
                "govuk_slug": "another-slug"
              },
              "name": "A Different Council",
              "country": "S",
              "type_name": "Unitary Authority",
              "generation_low": 1,
              "country_name": "Scotland",
              "type": "DIS"
            }
          }
          mapit_has_areas(described_class.local_authority_types, updated_name_ons_slug_and_tier)

          described_class.import_from_mapit

          expect(LocalAuthority.count).to eq(8)

          la = LocalAuthority.find_by(gss: 'S12000033')

          expect(la.name).to eq("A Different Council")
          expect(la.snac).to eq("XXXX")
          expect(la.slug).to eq("another-slug")
          expect(la.tier.name).to eq("district")
        end

        it 'skips updating if GSS or SNAC code is blank' do
          described_class.import_from_mapit
          updated_name_type_and_ons = {
            "2120": {
              "parent_area": nil,
              "generation_high": 1,
              "all_names": {},
              "id": 9999,
              "codes": {
                "ons": "",
                "gss": "S12000033",
                "unit_id": "30421",
                "govuk_slug": "different-council-slug"
              },
              "name": "A Different Council",
              "country": "S",
              "type_name": "Unitary Authority",
              "generation_low": 1,
              "country_name": "Scotland",
              "type": "UTA"
            },
            "2118": {
              "parent_area": nil,
              "generation_high": 1,
              "all_names": {},
              "id": 2118,
              "codes": {
                "ons": "00QB",
                "gss": "",
                "unit_id": "30111",
                "govuk_slug": "another-council-slug"
              },
              "name": "Another Council",
              "country": "S",
              "type_name": "Unitary Authority",
              "generation_low": 1,
              "country_name": "Scotland",
              "type": "UTA"
            }
          }

          mapit_has_areas(described_class.local_authority_types, updated_name_type_and_ons)

          described_class.import_from_mapit

          expect(LocalAuthority.count).to eq(8)

          la = LocalAuthority.find_by(gss: 'S12000033')
          expect(la.name).to eq("Aberdeen City Council")

          la2 = LocalAuthority.find_by(snac: '00QB')
          expect(la2.name).to eq("Aberdeenshire Council")
        end
      end

      context 'check imported data' do
        let(:importer) { described_class.new }
        let(:mapit_data) do
          {
            "2120": {
              "parent_area": nil,
              "generation_high": 1,
              "all_names": {},
              "id": 2120,
              "codes": {
                "ons": "00QA",
                "gss": "S12000033",
                "unit_id": "30421",
                "govuk_slug": "aberdeen-city-council"
              },
              "name": "Aberdeen City Council",
              "country": "S",
              "type_name": "Unitary Authority",
              "generation_low": 1,
              "country_name": "Scotland",
              "type": "UTA"
            }
          }
        end

        context 'when there are no local authorities missing from the import' do
          before do
            FactoryGirl.create(:local_authority, gss: 'S12000033')
            mapit_has_areas(described_class.local_authority_types, mapit_data)
          end

          it 'returns success response' do
            expect(importer.authorities_from_mapit).to be_successful
          end
        end

        context 'when a local authority is no longer in the import' do
          before do
            FactoryGirl.create(:local_authority, gss: 'S12000033')
            FactoryGirl.create(:local_authority, gss: 'S12000034')
            FactoryGirl.create(:local_authority, gss: 'S12000035')
            mapit_has_areas(described_class.local_authority_types, mapit_data)
          end

          it 'returns response with error about missing local authority' do
            response = importer.authorities_from_mapit
            expect(response).to_not be_successful
            expect(response.errors).to include(/2 LocalAuthorities are no longer in the import source/)
          end

          it 'does not delete anything' do
            importer.authorities_from_mapit
            expect(LocalAuthority.count).to eq(3)
          end
        end
      end
    end

    describe 'importing of local authorities with connecting parents' do
      let(:importer) { described_class.new }

      context "for local authorities with parents" do
        let(:parent_local_authority) { LocalAuthority.find_by(slug: 'buckinghamshire-county-council') }

        let(:county_and_district) do
          {
            "1724": {
              "parent_area": nil,
              "generation_high": 1,
              "all_names": {},
              "id": 1724,
              "codes": {
                "ons": "11",
                "gss": "E10000002",
                "unit_id": "11901",
                "govuk_slug": "buckinghamshire-county-council"
              },
              "name": "Buckinghamshire County Council",
              "country": "E",
              "type_name": "County council",
              "generation_low": 1,
              "country_name": "England",
              "type": "CTY"
            },
            "1999": {
              "parent_area": 1724,
              "generation_high": 1,
              "all_names": {},
              "id": 1999,
              "codes": {
                "ons": "11UB",
                "gss": "E07000999",
                "unit_id": "16999",
                "govuk_slug": "aylesbury-district-council"
              },
              "name": "Aylesbury District Council",
              "country": "E",
              "type_name": "District council",
              "generation_low": 1,
              "country_name": "England",
              "type": "DIS"
            }
          }
        end

        it 'reports a successful import' do
          mapit_has_areas(described_class.local_authority_types, county_and_district)
          expect(importer.authorities_from_mapit).to be_successful
        end

        it 'imports MapIt formatted json' do
          mapit_has_areas(described_class.local_authority_types, county_and_district)

          importer.authorities_from_mapit

          expect(LocalAuthority.count).to eq(2)

          la = LocalAuthority.find_by(slug: 'aylesbury-district-council')

          expect(la.name).to eq('Aylesbury District Council')
          expect(la.snac).to eq('11UB')
          expect(la.tier.name).to eq('district')
          expect(la.slug).to eq('aylesbury-district-council')
          expect(la.parent_local_authority_id).to eq(parent_local_authority.id)
        end
      end

      context "when a child local authority is an orphan" do
        it "does not trigger a success message" do
          orphan_child_authority = {
            "2120": {
              "parent_area": 99,
              "generation_high": 1,
              "all_names": {},
              "id": 2120,
              "codes": {
                "ons": "00QA",
                "gss": "S12000033",
                "unit_id": "30421",
                "govuk_slug": "aberdeen-city-council"
              },
              "name": "Aberdeen City Council",
              "country": "S",
              "type_name": "Unitary Authority",
              "generation_low": 1,
              "country_name": "Scotland",
              "type": "UTA",
            }
          }

          mapit_has_areas(described_class.local_authority_types, orphan_child_authority)

          response = importer.authorities_from_mapit

          expect(response).to_not be_successful
          expect(response.errors).to include("1 LocalAuthority is orphaned.\naberdeen-city-council\n")
        end
      end

      context "when there are orphaned and missing local authorities" do
        it "shows both errors in the response" do
          FactoryGirl.create(:local_authority, gss: 'S12000033', slug: "aberdeen-city-council")
          FactoryGirl.create(:local_authority, gss: 'S12000034', slug: "gotham-city-council")
          FactoryGirl.create(:local_authority, gss: 'S12000035', slug: "metropolis-city-council")

          orphan_child_authority = {
            "2120": {
              "parent_area": 99,
              "generation_high": 1,
              "all_names": {},
              "id": 2120,
              "codes": {
                "ons": "00QA",
                "gss": "S12000033",
                "unit_id": "30421",
                "govuk_slug": "aberdeen-city-council"
              },
              "name": "Aberdeen City Council",
              "country": "S",
              "type_name": "Unitary Authority",
              "generation_low": 1,
              "country_name": "Scotland",
              "type": "UTA",
            }
          }

          mapit_has_areas(described_class.local_authority_types, orphan_child_authority)

          response = importer.authorities_from_mapit

          expect(response).to_not be_successful
          expect(response.errors).to include("1 LocalAuthority is orphaned.\naberdeen-city-council\n")
          expect(response.errors).to include("2 LocalAuthorities are no longer in the import source.\ngotham-city-council\nmetropolis-city-council\n")
        end
      end
    end
  end
end
