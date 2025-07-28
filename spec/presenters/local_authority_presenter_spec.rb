require "support/url_status_presentation"

describe LocalAuthorityPresenter do
  it_behaves_like "a UrlStatusPresentation module"

  let(:local_authority) { double(:local_authority) }
  let(:presenter) { described_class.new(local_authority) }

  describe "#homepage_status" do
    it "returns the homepage URL's status description if a URL is present" do
      allow(local_authority).to receive(:homepage_url).and_return("http://example.com")
      allow(local_authority).to receive(:status).and_return("ok")
      expect(presenter.homepage_status).to eq("Good")
    end

    it 'returns "No link" if the homepage URL is set to nil' do
      allow(local_authority).to receive(:homepage_url).and_return(nil)
      expect(presenter.homepage_status).to eq("No link")
    end

    it 'returns "No link" if the homepage URL is set to an empty string' do
      allow(local_authority).to receive(:homepage_url).and_return("")
      expect(presenter.homepage_status).to eq("No link")
    end
  end

  describe "#homepage_link_last_checked" do
    it "returns the time the URL was last checked if a URL is present" do
      time = Timecop.freeze(Time.zone.now)
      allow(local_authority).to receive(:homepage_url).and_return("http://example.com")
      allow(local_authority).to receive(:link_last_checked).and_return(time - (60 * 60))

      expect(presenter.homepage_link_last_checked).to eq("about 1 hour ago")
    end

    it "returns an empty string if the homepage URL is set to nil" do
      allow(local_authority).to receive(:homepage_url).and_return(nil)
      expect(presenter.homepage_link_last_checked).to be_empty
    end

    it "returns an empty string if the homepage URL is set to an empty string" do
      allow(local_authority).to receive(:homepage_url).and_return("")
      expect(presenter.homepage_link_last_checked).to be_empty
    end
  end

  describe "#authority_status" do
    it "returns active if currently active and no end date specified" do
      allow(local_authority).to receive(:active?).and_return(true)
      allow(local_authority).to receive(:active_end_date).and_return(nil)
      expect(presenter.authority_status).to eq("active")
    end

    it "returns active but... if currently active but has an end date" do
      allow(local_authority).to receive(:active?).and_return(true)
      allow(local_authority).to receive(:active_end_date).and_return(Time.zone.now + 1.year)
      expect(presenter.authority_status).to eq("active, but being retired")
    end

    it "returns inactive if currently inactive" do
      allow(local_authority).to receive(:active?).and_return(false)
      expect(presenter.authority_status).to eq("inactive")
    end
  end

  describe "#should_display_end_notes?" do
    it "returns false if currently active and no end date specified" do
      allow(local_authority).to receive(:active?).and_return(true)
      allow(local_authority).to receive(:active_end_date).and_return(nil)
      expect(presenter.should_display_end_notes?).to be false
    end

    it "returns true if currently active but has an end date" do
      allow(local_authority).to receive(:active?).and_return(true)
      allow(local_authority).to receive(:active_end_date).and_return(Time.zone.now + 1.year)
      expect(presenter.should_display_end_notes?).to be true
    end

    it "returns true if currently inactive" do
      allow(local_authority).to receive(:active?).and_return(false)
      expect(presenter.should_display_end_notes?).to be true
    end
  end

  describe "#active_end_date_title" do
    it "returns due-to-become message if authority is not yet inactive" do
      allow(local_authority).to receive(:active?).and_return(true)
      expect(presenter.active_end_date_title).to eq("Date authority is due to become inactive")
    end

    it "returns became message if authority is now inactive" do
      allow(local_authority).to receive(:active?).and_return(false)
      expect(presenter.active_end_date_title).to eq("Date authority became inactive")
    end
  end

  describe "#homepage_status_colour" do
    it "returns yellow if the status is 'caution'" do
      allow(local_authority).to receive(:homepage_url).and_return("http://example.com")
      allow(local_authority).to receive(:status).and_return("caution")

      expect(presenter.homepage_status_colour).to eq("yellow")
    end

    it "returns red if the status is 'broken'" do
      allow(local_authority).to receive(:homepage_url).and_return("http://example.com")
      allow(local_authority).to receive(:status).and_return("broken")

      expect(presenter.homepage_status_colour).to eq("red")
    end

    it "returns green if the status is not 'broken' or 'caution'" do
      allow(local_authority).to receive(:homepage_url).and_return("http://example.com")
      allow(local_authority).to receive(:status).and_return("ok")

      expect(presenter.homepage_status_colour).to eq("green")
    end
  end
end
