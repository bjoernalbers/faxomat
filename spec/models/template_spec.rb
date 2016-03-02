describe Template do
  let(:template) { build(:template) }

  it 'has valid factory' do
    expect(template).to be_valid
  end

  describe '.default' do
    it 'returns first template' do
      2.times { create(:template) }
      expect(Template.default).to eq Template.first
    end
  end

  it { expect(template).to have_attached_file(:logo) }

  it { expect(template).to validate_attachment_content_type(:logo).
    allowing('image/png').rejecting('application/pdf') }
end
