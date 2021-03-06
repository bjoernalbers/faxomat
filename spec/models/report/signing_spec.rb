describe Report::Signing do
  subject { build(:report_signing) }
  let(:other) { create(:report_signing) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Unterzeichnung'
  end

  [ :signature_path, :full_name, :suffix ].each do |method|
    it { should delegate_method(method).to(:user) }
  end

  describe '#report' do
    it 'is translated' do
      expect(described_class.human_attribute_name(:report)).to eq 'Bericht'
    end

    it { should belong_to(:report) }

    it 'must be present' do
      subject.report = nil
      expect(subject).to be_invalid
      expect(subject.errors[:report]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe '#user' do
    it 'is translated' do
      expect(described_class.human_attribute_name(:user)).to eq 'Arzt'
    end

    it { should belong_to(:user) }

    it 'must be present' do
      subject.user = nil
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'can be non-unique' do
      subject.user = other.user
      expect(subject).to be_valid
      expect { subject.save!(validate: false) }.not_to raise_error
    end

    it 'must not have signed report' do
      subject.attributes = { report: other.report, user: other.user }
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to include('hat Bericht bereits unterschrieben')
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe '#destroy' do
    subject { create(:report_signing, report: report) }

    context 'with pending report' do
      let(:report) { create(:pending_report) }

      it 'destroys record' do
        expect { subject.destroy }.to change(subject, :persisted?)
      end
    end

    context 'with verified report' do
      let(:report) { create(:verified_report) }

      it 'does not destroy record' do
        expect { subject.destroy }.not_to change(subject, :persisted?)
      end

      it 'adds error' do
        subject.destroy
        expect(subject.errors[:report]).to be_present
      end
    end
  end
end
