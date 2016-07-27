describe Export::Filename do
  let(:document) { create(:document, title: 'Chunky Bacon') }
  subject { described_class.new(document) }

  describe '#to_s' do
    it 'joins document title and id' do
      expect(subject.to_s).to eq "Chunky Bacon - Dokument #{document.id}.pdf"
    end
  end
end
