describe Delivery do
  let(:subject) { build(:delivery) }

  it_behaves_like 'a deliverable'

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe '#status' do
    it 'can be :active' do
      subject.status = :active
      expect(subject).to be_active
    end

    it 'can be :completed' do
      subject.status = :completed
      expect(subject).to be_completed
    end

    it 'can be :aborted' do
      subject.status = :aborted
      expect(subject).to be_aborted
    end

    it 'defaults to :active' do
      expect(subject).to be_active
    end

    it 'must be present in database' do
      subject.save
      expect {
        subject.update_column(:status, nil)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'accepts no unknown value' do
      expect{ subject.status = :chunky_bacon }.to raise_error(ArgumentError)
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
