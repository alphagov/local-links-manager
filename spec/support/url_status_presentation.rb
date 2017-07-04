RSpec.shared_examples "a UrlStatusPresentation module" do
  describe '#label_status_class' do
    let(:presenter) { described_class.new(@link) }

    it 'returns nil if the status is not present' do
      @link = double(:Link, status: nil)
      expect(presenter.label_status_class).to be_nil
    end

    it 'returns "label label-success" if the status is "200"' do
      @link = double(:Link, status: '200')
      expect(presenter.label_status_class).to eq('label label-success')
    end

    it 'returns nil if the status is "Timeout Error"' do
      @link = double(:Link, status: 'Timeout Error')
      expect(presenter.label_status_class).to be_nil
    end

    it 'returns "label label-danger" for any other status' do
      @link = double(:Link, status: '404')
      expect(presenter.label_status_class).to eq('label label-danger')
    end
  end

  describe '#last_checked' do
    let(:presenter) { described_class.new(@link) }

    it 'returns how long ago the link was last checked if it has been checked' do
      time = Timecop.freeze(Time.now)
      @link = double(:Link, link_last_checked: time - (60 * 60))
      expect(presenter.last_checked).to eq("about 1 hour ago")
    end

    it 'returns "Link not checked if the link has not last checked time' do
      @link = double(:Link, link_last_checked: nil)
      expect(presenter.last_checked).to eq("Link not checked")
    end
  end
end
