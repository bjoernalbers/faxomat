shared_examples 'a deliverable' do
  describe '#document' do
    it { should belong_to(:document) }

    it 'must be present' do
      subject.document = nil
      expect(subject).to be_invalid
      expect(subject.errors[:document]).to be_present
    end

    it 'must be present in database' do
      subject.save
      expect {
        subject.update_column(:document_id, nil)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

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

    it 'is translated' do
      expect(described_class.human_attribute_name(:document)).
        to eq 'Dokument'
    end
  end
end
