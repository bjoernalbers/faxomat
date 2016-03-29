describe Document do
  let(:subject) { build(:document) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it { expect(subject).to validate_presence_of(:title) }

  it { should have_attached_file(:file) }

  it { should validate_attachment_presence(:file) }

  it { should validate_attachment_content_type(:file).
    allowing('application/pdf').
    rejecting('image/jpeg', 'image/png') }

  describe '#file_fingerprint' do
    it 'gets stored on save' do
      #expect(subject.file_fingerprint).not_to be_present
      subject.save
      expect(subject.file_fingerprint).to be_present
      expect(subject.file_fingerprint).
        to eq Digest::MD5.file(subject.file.path).to_s
    end
  end
end
