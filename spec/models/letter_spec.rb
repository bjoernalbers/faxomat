describe Letter do
  let(:letter) { build(:letter) }

  # Associations
  [ :report, :user ].each do |association|
    it { expect(letter).to belong_to(association) }
  end

  # Required attributes
  [ :report, :user ].each do |attribute|
    it { expect(letter).to validate_presence_of(attribute) }
  end

  it { expect(letter).to validate_uniqueness_of(:report_id) }

  it 'can not be stored with non-unique report_id' do
    create(:letter, report: letter.report)
    expect{ letter.save!(validate: false) }.to raise_error
  end

  describe '#document' do
    let(:path) { Rails.root.join('spec', 'support', 'sample.pdf') }

    it { expect(letter).to have_attached_file(:document) }

    it { expect(letter).to validate_attachment_content_type(:document).
      allowing('application/pdf').rejecting('text/plain') }

    context 'on create' do
      before do
        expect(letter).to be_new_record
        expect(letter.document).not_to be_present
      end

      it 'gets assigned' do
        letter.save!
        expect(letter.document).to be_present
      end

      it 'gets overwritten' do
        File.open(path) do |file|
          letter.document = file
          letter.save!
        end
        expect(FileUtils.identical?(letter.document.path, path)).to be false
      end

      it 'stores the fingerprint(?)'
    end

    context 'on update' do
      it 'is invalid when nil'
      it 'does not get re-assigned'
    end
  end

  context 'with verified report' do
    let(:letter) { build(:letter, report: build(:verified_report)) }

    it 'is valid' do
      expect(letter).to be_valid
    end
  end

  context 'with pending report' do
    let(:letter) { build(:letter, report: build(:pending_report)) }

    it 'is invalid' do
      expect(letter).to be_invalid
      expect(letter.errors[:report]).to be_present
    end
  end

  context 'with canceled report on create' do
    let(:letter) { build(:letter, report: build(:pending_report)) }

    it 'is invalid' do
      expect(letter).to be_invalid
      expect(letter.errors[:report]).to be_present
    end
  end

  context 'with canceled report on update' do
    let(:letter) { create(:letter, report: build(:verified_report)) }

    before do
      letter.report.update!(status: :canceled)
      letter.reload
    end

    it 'is invalid' do
      expect(letter.report).to be_canceled
      expect(letter).to be_valid
    end
  end
end
