RSpec.describe LocalAuthority, type: :model do
  describe "validations" do
    before(:each) do
      create(:local_authority)
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:gss) }
    it { should validate_presence_of(:snac) }
    it { should validate_presence_of(:slug) }

    it { should validate_uniqueness_of(:gss) }
    it { should validate_uniqueness_of(:snac) }
    it { should validate_uniqueness_of(:slug) }

    describe "tier_id" do
      [Tier.county, Tier.district, Tier.unitary].each do |tier|
        it { should allow_value(tier).for(:tier_id) }
      end

      it { should_not allow_value(-1).for(:tier_id) }
      it { should_not allow_value(nil).for(:tier_id) }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:links) }
  end

  describe "#provided_services" do
    let!(:all_service) { create(:service, :all_tiers) }
    let!(:county_service) { create(:service, :county_unitary) }
    let!(:district_service) { create(:service, :district_unitary) }
    let!(:nil_service) { create(:service) }
    let!(:disabled_service) { create(:disabled_service, :district_unitary) }

    context 'for a "district" LA' do
      subject { create(:district_council) }

      it "returns all and district/unitary services that are enabled" do
        expect(subject.provided_services).to match_array([all_service, district_service])
      end
    end

    context 'for a "county" LA' do
      subject { create(:county_council) }

      it "returns all and county/unitary services that are enabled" do
        expect(subject.provided_services).to match_array([all_service, county_service])
      end
    end

    context 'for a "unitary" LA' do
      subject { create(:unitary_council) }

      it "returns all, district/unitary, and county/unitary services that are enabled" do
        expect(subject.provided_services).to match_array([all_service, county_service, district_service])
      end
    end
  end

  describe "#tier" do
    it "is a string representation of the Tier" do
      local_authority = create(:district_council)
      expect(local_authority.tier).to eql "district"
    end
  end

  describe "#update_broken_link_count" do
    it "updates the broken_link_count" do
      link = create(:link, status: "broken")
      local_authority = link.local_authority
      expect { local_authority.update_broken_link_count }
        .to change { local_authority.broken_link_count }
        .from(0).to(1)
    end

    it "ignores unchecked links" do
      local_authority = create(:local_authority, broken_link_count: 1)
      create(:link, local_authority: local_authority, status: "pending")
      expect { local_authority.update_broken_link_count }
        .to change { local_authority.broken_link_count }
        .from(1).to(0)
    end

    it "ignores broken links that are not provided by the local_authority" do
      disabled_service_link = create(:link_for_disabled_service, status: "broken")
      local_authority = disabled_service_link.local_authority

      expect { local_authority.update_broken_link_count }
        .to_not(change { local_authority.broken_link_count })
    end
  end
end
