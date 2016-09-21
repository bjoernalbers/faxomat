describe Report::Verification do
  let(:report) { create(:report) }
  let(:user) { create(:user) }
  subject { described_class.new(report: report, user: user) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Vidierung'
  end

  describe '#report' do
    it 'is translated' do
      expect(described_class.human_attribute_name(:report)).to eq 'Bericht'
    end

    it 'must be present' do
      subject.report = nil
      expect(subject).to be_invalid
      expect(subject.errors[:report]).to be_present
    end

    it 'must be unreleased' do
      create(:report_release, report: report)
      expect(subject).to be_invalid
      expect(subject.errors[:report]).to include('wurde bereits freigegeben')
    end
  end

  describe '#user' do
    it 'is translated' do
      expect(described_class.human_attribute_name(:user)).to eq 'Arzt'
    end

    it 'must be present' do
      subject.user = nil
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to be_present
    end

    it 'must not have signed report' do
      create(:report_signature, report: report, user: user)
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to include('hat Bericht bereits unterschrieben')
    end
  end

  describe '#save' do
    it 'signs report' do
      expect {
        subject.save
      }.to change { report.signatures.where(user: user).count }.by(1)
    end

    it 'verifies report' do
      subject.save
      expect(report).to be_verified
    end

    it 'returns true' do
      expect(subject.save).to eq true
    end

    context 'with unauthorized user' do
      let(:user) { create(:unauthorized_user) }

    end

    describe 'when transaction fails' do
      let(:bomb) { double(:bomb) }

      before do
        allow(bomb).to receive(:save!) { raise ActiveRecord::ActiveRecordError }
        subject.send(:models) << bomb
      end

      it 'does not save signature' do
        expect { subject.save }.not_to change { report.signatures.count }
      end

      it 'does not verify report' do
        subject.save
        expect(report.reload).to be_pending
      end

      it 'returns false' do
        expect(subject.save).to eq false
      end
    end
  end
end
