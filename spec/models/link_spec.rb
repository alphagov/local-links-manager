require 'rails_helper'

RSpec.describe Link, type: :model do
  describe 'validations' do
    subject(:link) { FactoryGirl.create(:link) }

    it { is_expected.to validate_presence_of(:local_authority) }
    it { is_expected.to validate_presence_of(:service_interaction) }
    it { is_expected.to validate_uniqueness_of(:service_interaction_id).scoped_to(:local_authority_id) }

    describe '#url' do
      it 'disallows urls without schemes' do
        is_expected.not_to allow_value('example.com').for(:url).with_message('is not a URL')
      end

      it 'disallows urls without a domain' do
        is_expected.not_to allow_value('com').for(:url).with_message('is not a URL')
      end

      it 'allows http urls' do
        is_expected.to allow_value('http://example.com').for(:url)
      end

      it 'allows https urls' do
        is_expected.to allow_value('https://example.com').for(:url)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:local_authority) }
    it { is_expected.to belong_to(:service_interaction) }

    it { is_expected.to have_one(:service).through(:service_interaction) }
    it { is_expected.to have_one(:interaction).through(:service_interaction) }
  end

  describe '.for_service' do
    it 'fetches all the links for the supplied service' do
      service_1 = FactoryGirl.create(:service, label: 'Service 1', lgsl_code: 1)
      service_2 = FactoryGirl.create(:service, label: 'Service 2', lgsl_code: 2)

      interaction_1 = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 1)
      interaction_2 = FactoryGirl.create(:interaction, label: 'Interaction 2', lgil_code: 2)

      service_interaction_1_1 = FactoryGirl.create(:service_interaction, service: service_1, interaction: interaction_1)
      service_interaction_1_2 = FactoryGirl.create(:service_interaction, service: service_1, interaction: interaction_2)
      service_interaction_2_2 = FactoryGirl.create(:service_interaction, service: service_2, interaction: interaction_1)

      local_authority_1 = FactoryGirl.create(:local_authority, name: 'Aberdeen', gss: 'S100000001', snac: '00AB1')
      local_authority_2 = FactoryGirl.create(:local_authority, name: 'Aberdeenshire', gss: 'S100000002', snac: '00AB2')

      link_1 = FactoryGirl.create(:link, local_authority: local_authority_1, service_interaction: service_interaction_1_1)
      link_2 = FactoryGirl.create(:link, local_authority: local_authority_1, service_interaction: service_interaction_1_2)
      FactoryGirl.create(:link, local_authority: local_authority_1, service_interaction: service_interaction_2_2)
      link_4 = FactoryGirl.create(:link, local_authority: local_authority_2, service_interaction: service_interaction_1_1)

      expect(Link.for_service(service_1)).to match_array([link_1, link_2, link_4])
    end

    context 'to avoid n+1 queries' do
      let(:service) { FactoryGirl.create(:service) }

      before do
        interaction = FactoryGirl.create(:interaction)
        service_interaction = FactoryGirl.create(:service_interaction, service: service, interaction: interaction)
        local_authority = FactoryGirl.create(:local_authority)
        FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction)
      end

      subject(:links) { Link.for_service(service) }

      it 'preloads the service interaction on the fetched records' do
        expect(links.first.association(:service_interaction)).to be_loaded
      end

      it 'preloads the service of the service interaction on the fetched records' do
        expect(links.first.service_interaction.association(:service)).to be_loaded
      end

      it 'preloads the interaction of the service interaction on the fetched records' do
        expect(links.first.service_interaction.association(:interaction)).to be_loaded
      end
    end
  end

  describe '.retrieve' do
    let!(:service_1) { FactoryGirl.create(:service, label: 'Service 1', lgsl_code: 1) }

    let!(:interaction_1) { FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 1) }

    let!(:service_interaction_1_1) { FactoryGirl.create(:service_interaction, service: service_1, interaction: interaction_1) }

    let!(:local_authority_1) { FactoryGirl.create(:local_authority, name: 'Aberdeen', gss: 'S100000001', snac: '00AB1') }

    let!(:expected_link) { FactoryGirl.create(:link, local_authority: local_authority_1, service_interaction: service_interaction_1_1) }

    let(:params) {
      {
        local_authority_slug: local_authority_1.slug,
        service_slug: service_1.slug,
        interaction_slug: interaction_1.slug
      }
    }

    subject(:link) { Link.retrieve(params) }

    it 'fetches the correct link for the service' do
      expect(link.url).to eq(expected_link.url)
    end
  end

  describe "before_update" do
    it "sets the link status and last checked time to nil if the link is updated and does not already exist" do
      @link = FactoryGirl.create(:link, status: "200", link_last_checked: Time.now)
      @link.url = "http://example.com"
      @link.save!
      expect(@link.status).to be_nil
      expect(@link.link_last_checked).to be_nil
    end

    it "sets the link status and last checked time to an existing url's status and last checked time" do
      time = Timecop.freeze("2016-07-14 11:34:09 +0100")
      @link_1 = FactoryGirl.create(:link, url: "http://example.com/thing", status: "200", link_last_checked: Time.now)
      @link_2 = FactoryGirl.create(:link, url: "http://example.com", status: "200", link_last_checked: time)
      @link_1.url = "http://example.com"
      @link_1.save!
      expect(@link_1.status).to eq(@link_2.status)
      expect(@link_1.link_last_checked).to eq(@link_2.link_last_checked)
    end

    it "sets the link and last checked time to an existing homepage url status and link last checked time" do
      @local_authority = FactoryGirl.create(:local_authority, status: "404", link_last_checked: "2016-07-14 11:34:09 +0100")
      @link = FactoryGirl.create(:link, url: "http://example.com/thing", status: "200", link_last_checked: Time.now)
      @link.url = "http://www.angus.gov.uk"
      @link.save!

      expect(@link.status).to eq(@local_authority.status)
      expect(@link.link_last_checked).to eq(@local_authority.link_last_checked)
    end
  end

  describe "before_create" do
    it "sets the link's status and last checked time to an existing url's status and last checked time" do
      @link_1 = FactoryGirl.create(:link, url: "http://example.com/thing", status: "200", link_last_checked: "2016-07-14 11:34:09 +0100")
      @link_2 = FactoryGirl.create(:link, url: "http://example.com/thing")
      expect(@link_2.status).to eq(@link_1.status)
      expect(@link_2.link_last_checked).to eq(@link_1.link_last_checked)
    end
  end

  it "sets the link's status and last checked time to nil if there is not already an existing URL" do
    @link = FactoryGirl.create(:link, url: "http://example.com/thing")
    expect(@link.status).to be nil
    expect(@link.link_last_checked).to be nil
  end
end
