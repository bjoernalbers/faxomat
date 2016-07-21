describe Delivery do
  let(:subject) { build(:delivery) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe '#document' do
    it { should belong_to(:document) }

    it { should validate_presence_of(:document) }
    
    it 'must be released for delivery on create' do
      report = create(:pending_report)
      document = create(:document, report: report)
      subject = build(:delivery, document: document)
      expect(document).not_to be_released_for_delivery
      expect(subject).to be_invalid
      expect(subject.errors[:document]).to be_present

      report.update! status: :verified
      expect(document).to be_released_for_delivery
      expect(subject).to be_valid
      
      subject.save
      report.update! status: :canceled
      expect(document).not_to be_released_for_delivery
      expect(subject).to be_valid
    end
  end

  describe '#status' do
    it 'can be :active' do
      subject = build(:active_delivery)
      expect(subject).to be_active
    end

    it 'can be :completed' do
      subject = build(:completed_delivery)
      expect(subject).to be_completed
    end

    it 'can be :aborted' do
      subject = build(:aborted_delivery)
      expect(subject).to be_aborted
    end

    it 'defaults to :active' do
      expect(subject).to be_active
    end

    it 'must be present in database' do
      subject.status = nil
      expect{ subject.save!(validate: false) }.
        to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'accepts no unknown value' do
      expect{ subject.status = 'chunky bacon' }.
        to raise_error(ArgumentError)
    end
  end

  describe '#destroy' do
    let(:message) { 'Nur abgebrochene Versendungen können gelöscht werden.' }

    it 'destroys aborted delivery' do
      subject = create(:aborted_delivery)
      subject.destroy
      expect(subject).to be_destroyed
    end

    it 'does not destroy completed delivery' do
      subject = create(:completed_delivery)
      subject.destroy
      expect(subject).not_to be_destroyed
      expect(subject.errors[:base]).to include(message)
    end
    
    it 'does not destroy active delivery' do
      subject = create(:active_delivery)
      subject.destroy
      expect(subject).not_to be_destroyed
      expect(subject.errors[:base]).to include(message)
    end
  end

  describe '.active_or_completed' do
    let(:subject) { described_class.active_or_completed }

    it 'includes active delivery' do
      delivery = create(:active_delivery)
      expect(subject).to include delivery
    end

    it 'includes completed delivery' do
      delivery = create(:completed_delivery)
      expect(subject).to include delivery
    end

    it 'excludes aborted delivery' do
      delivery = create(:aborted_delivery)
      expect(subject).not_to include delivery
    end
  end

end
