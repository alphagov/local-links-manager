require 'rails_helper'
require 'local-links-manager/check_links/link_status_updater'

describe LocalLinksManager::CheckLinks::LinkStatusUpdater do
  let(:link_checker) { double :link_checker }
  subject(:status_updater) { described_class.new(link_checker) }

  before do
    @time = Timecop.freeze('2016-06-21 09:26:56 +0100')
  end

  describe '#update' do
    context "with links for enabled Services" do
      let(:local_authority) { FactoryGirl.create(:local_authority, broken_link_count: 3) }
      let(:service) { FactoryGirl.create(:service, broken_link_count: 3) }
      let!(:link_1) { FactoryGirl.create(:link, local_authority: local_authority, service: service, url: 'http://www.example.com', status: 500) }
      let!(:link_2) { FactoryGirl.create(:link, local_authority: local_authority, service: service, url: 'http://www.example.com/exampl.html', status: 404) }

      # missing links are not fixed via link checker
      let!(:missing_link) { FactoryGirl.create(:link, local_authority: local_authority, service: service, url: nil) }

      it 'updates the link\'s status code and link last checked time in the database' do
        allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)

        status_updater.update

        expect(link_1.reload.status).to eq('200')
        expect(link_2.reload.link_last_checked).to eq(@time)
      end

      it 'updates the Local Authorities broken_link_count' do
        allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)
        expect { status_updater.update }
          .to change { local_authority.reload.broken_link_count }
          .from(3).to(1)
      end

      it 'updates the Service\'s broken_link_count' do
        allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)
        expect { status_updater.update }
          .to change { service.reload.broken_link_count }
          .from(3).to(1)
      end

      context "with duplicate links" do
        let!(:duplicate_link) { FactoryGirl.create(:link, url: link_2.url) }

        it 'updates links with non-unique URLs' do
          allow(link_checker).to receive(:check_link).and_return(status: '200', checked_at: @time)

          status_updater.update

          expect(duplicate_link.reload.status).to eq('200')
          expect(duplicate_link.reload.link_last_checked).to eq(@time)
        end
      end
    end
  end

  context "with links for disabled Services" do
    let!(:disabled_service_link) { FactoryGirl.create(:link_for_disabled_service) }

    it 'does not test links' do
      expect(link_checker).not_to receive(:check_link)

      status_updater.update
    end
  end
end
