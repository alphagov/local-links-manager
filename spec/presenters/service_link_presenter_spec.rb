require 'support/url_status_presentation'

describe ServiceLinkPresenter do
  describe '#status_description' do
    let(:presenter) { described_class.new(@link, view_context: nil) }

    it 'returns "Missing" if the URL is not present' do
      @link = double(:Link, status: nil, url: nil)
      expect(presenter.link_status).to eq('Missing')
    end

    it 'returns an empty string if status is not present' do
      @link = double(:Link, status: nil, url: "http://example.com")
      expect(presenter.link_status).to eq('')
    end

    it 'returns "Good" if the status is "200"' do
      @link = double(:Link, status: '200', url: "http://example.com")
      expect(presenter.link_status).to eq('Good')
    end

    it 'returns "Broken Link 404" if the status is "404"' do
      @link = double(:Link, status: '404', url: "http://example.com")
      expect(presenter.link_status).to eq('404')
    end

    it 'returns "Server Error 503" if the status is "503"' do
      @link = double(:Link, status: '503', url: "http://example.com")
      expect(presenter.link_status).to eq('503')
    end

    it 'returns the status name if the status is an unexpected status' do
      @link = double(:Link, status: "Another Error", url: "http://example.com")
      expect(presenter.link_status).to eq("Another Error")
    end
  end
end
