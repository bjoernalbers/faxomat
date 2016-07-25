describe Delivery do
  let(:subject) { build(:delivery) }

  it_behaves_like 'a deliverable'

  it 'has valid factory' do
    expect(subject).to be_valid
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
