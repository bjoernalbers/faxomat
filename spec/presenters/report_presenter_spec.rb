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
    context 'when missing' do
      before do
        allow(presenter).to receive(:recipient).
          and_return double(salutation: nil)
      end

      it 'returns default salutation' do
        expect(presenter.salutation).to eq 'Sehr geehrte Kollegen,'
      end
    end

    context 'when present' do
      before do
        allow(presenter).to receive(:recipient).
          and_return double(salutation: 'Hallo Leute,')
      end

      it 'returns recipient salutation' do
        expect(presenter.salutation).to eq 'Hallo Leute,'
      end
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

  [
    :study,
    :anamnesis,
    :diagnosis,
    :findings,
    :evaluation,
    :procedure,
    :clinic
  ].each do |method|
    describe "##{method}" do
      it "returns report #{method}" do
        expect(presenter.send(method)).to eq report.send(method)
      end
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

  describe '#signature_path' do
    it 'returns path to user signature' do
      allow(presenter).to receive(:user).
        and_return double(signature_path: 'fancy_signature.png')
      expect(presenter.signature_path).to eq 'fancy_signature.png'
    end
  end

  describe '#watermark' do
    it 'with pending report returns "ENTWURF"' do
      allow(presenter).to receive(:report).
        and_return build(:pending_report)
      expect(presenter.watermark).to eq 'ENTWURF'
    end

    it 'with verified report returns nil' do
      allow(presenter).to receive(:report).
        and_return build(:verified_report)
      expect(presenter.watermark).to be nil
    end

    it 'with canceled report' do
      allow(presenter).to receive(:report).
        and_return build(:canceled_report)
      expect(presenter.watermark).to eq 'STORNIERT'
    end
  end

  describe '#include_signature?' do
    it 'is true with report verification' do
      allow(report).to receive(:verified?).and_return(true)
      expect(presenter.include_signature?).to be true
    end

    it 'is false without report verification' do
      allow(report).to receive(:verified?).and_return(false)
      expect(presenter.include_signature?).to be false
    end
  end
end
