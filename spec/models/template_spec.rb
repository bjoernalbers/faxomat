describe Template do
  let(:subject) { build(:template) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe '.default' do
    let(:subject) { described_class.default }

    context 'without templates' do
      it 'returns empty template' do
        build(:template).attributes.keys.each do |attr|
          #expect(subject.send(attr.to_sym)).to be nil
          expect(subject.send(attr.to_sym)).to eq ''
        end
      end
    end

    context 'with templates' do
      let!(:first) { create(:template) }
      let!(:second) { create(:template) }

      it 'returns first template' do
        expect(subject).to eq first
      end
    end
  end

  describe '#logo' do
    it { expect(subject).to have_attached_file(:logo) }

    it { expect(subject).to validate_attachment_content_type(:logo).
      allowing('image/png').rejecting('application/pdf') }
  end
end
