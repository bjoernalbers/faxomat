describe Report::Release do
  subject { build(:report_release) }
  let(:other) { create(:report_release) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Berichtfreigabe'
  end

  it 'has factory for uncanceled reports' do
    subject = build(:uncanceled_report_release)
    expect(subject.canceled_at).not_to be
    expect(subject).not_to be_canceled
  end

  it 'has factory for canceled reports' do
    subject = build(:canceled_report_release)
    expect(subject.canceled_at).to be
    expect(subject).to be_canceled
  end

  describe '.canceled' do
    subject { described_class.canceled }

    it 'includes canceled records' do
      expect(subject).to include(create(:canceled_report_release))
    end

    it 'excludes uncanceld records' do
      expect(subject).not_to include(create(:uncanceled_report_release))
    end
  end

  describe '.uncanceled' do
    subject { described_class.uncanceled }

    it 'includes uncanceled records' do
      expect(subject).to include(create(:uncanceled_report_release))
    end

    it 'excludes canceld records' do
      expect(subject).not_to include(create(:canceled_report_release))
    end
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

    it 'must be unique' do
      subject.report = other.report
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

    it 'must be authorized' do
      subject.user = build(:unauthorized_user)
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to be_present
      subject.user = build(:authorized_user)
      expect(subject).to be_valid
    end
  end

  describe '#cancel!' do
    it 'updates canceled_at when uncanceled' do
      subject = create(:uncanceled_report_release)
      expect { subject.cancel! }.to change { subject.reload.canceled_at }
    end

    it 'does not update canceled_at when canceled' do
      subject = create(:canceled_report_release)
      expect { subject.cancel! }.not_to change { subject.reload.canceled_at }
    end
  end

  describe 'updates documents' do
    let(:report) { create(:report) }
    let(:document) { create(:document, report: report) }

    it 'on create' do
      subject = build(:report_release, report: report)
      expect { subject.save }.to change { document.reload.fingerprint }
    end

    it 'on update' do
      subject = create(:report_release, report: report)
      expect { subject.save }.to change { document.reload.fingerprint }
    end

    it 'on destroy' do
      subject = create(:report_release, report: report)
      expect { subject.destroy }.to change { document.reload.fingerprint }
    end
  end
end
