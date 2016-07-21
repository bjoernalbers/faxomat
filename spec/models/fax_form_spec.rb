describe FaxForm do
  let(:subject) { build(:fax_form) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it { expect(subject).to validate_presence_of(:title) }

  it { expect(subject).to validate_presence_of(:phone) }

  it { expect(subject).to validate_presence_of(:document) }

  it { expect(subject).to validate_presence_of(:printer) }

  describe '#save' do
    before do
      Rails.application.load_seed
    end

    context 'when valid' do
      it 'creates print job' do
        expect {
          subject.save
        }.to change(PrintJob, :count).by(1)
      end

      it 'returns true' do
        expect(subject.save).to eq true
      end
    end

    context 'when invalid' do
      let(:subject) { described_class.new }

      it 'returns false' do
        expect(subject.save).to eq false
      end
    end
  end
end
