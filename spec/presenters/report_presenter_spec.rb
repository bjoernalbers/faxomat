describe ReportPresenter do
  let(:report)    { build(:report) }
  let(:presenter) { ReportPresenter.new(report, view) }

  describe '#patient_name' do
    it 'returns patient display name' do
      allow(presenter).to receive(:patient).
        and_return double(display_name: 'Chunky Bacon')
      expect(presenter.patient_name).to eq 'Chunky Bacon'
    end
  end

  describe '#recipient_name' do
    it 'returns full recipient name' do
      allow(presenter).to receive(:recipient).
        and_return double(full_name: 'Chunky Bacon')
      expect(presenter.recipient_name).to eq 'Chunky Bacon'
    end
  end

  describe '#recipient_address' do
    it 'returns full recipient address' do
      allow(presenter).to receive(:recipient).
        and_return double(full_address: 'Sesamstraße 1')
      expect(presenter.recipient_address).to eq 'Sesamstraße 1'
    end
  end

  describe '#recipient_salutation' do
    it 'returns default salutation' do
      expect(presenter.salutation).to eq 'Sehr geehrte Kollegen,'
    end
  end

  describe '#report_date' do
    it 'returns report creation date when present' do
      allow(presenter).to receive(:report).
        and_return double(created_at: Time.zone.parse('2015-09-18'))
      expect(presenter.report_date).to eq '18.9.2015'
    end

    it 'returns nil when report creation date missing' do
      allow(presenter).to receive(:report).
        and_return double(created_at: nil)
      expect(presenter.report_date).to be nil
    end
  end

  describe '#subject' do
    it 'returns report subject' do
      allow(presenter).to receive(:report).
        and_return double(subject: 'hi!')
      expect(presenter.subject).to eq 'hi!'
    end
  end

  describe '#content' do
    it 'returns report content' do
      allow(presenter).to receive(:report).
        and_return double(content: 'no worries, all is fine')
      expect(presenter.content).to eq 'no worries, all is fine'
    end
  end

  describe '#valediction' do
    it 'returns default salutation' do
      expect(presenter.valediction).to eq 'Mit freundlichen Grüßen'
    end
  end

  describe '#physician_name' do
    it 'returns full recipient name' do
      allow(presenter).to receive(:user).
        and_return double(full_name: 'Dr. Gregory House')
      expect(presenter.physician_name).to eq 'Dr. Gregory House'
    end
  end

  describe '#physician_signature' do
    it 'returns image path'
  end

  describe '#watermark' do
    it 'with pending report returns "ENTWURF"' do
      report.pending!
      expect(presenter.watermark).to eq 'ENTWURF'
    end

    it 'with approved report returns nil' do
      report.approved!
      expect(presenter.watermark).to be nil
    end

    it 'with canceled report' do
      report.canceled!
      expect(presenter.watermark).to eq 'STORNIERT'
    end
  end
end
