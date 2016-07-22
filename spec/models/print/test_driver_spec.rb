describe Print::TestDriver do
  let(:subject) { described_class.new(build(:print)) }

  describe '.statuses' do
    it 'returns empty hash' do
      expect(described_class.statuses('printer')).to eq({})
    end
  end

  describe '#run' do
    it 'always returns true' do
      expect(subject.run).to eq true
    end
  end

  describe '#job_id' do
    it 'returns integer' do
      expect(subject.job_id).to be_a Integer
    end

    it 'returns 6 digits' do
      expect(subject.job_id.to_s.length).to eq 6
    end

    it 'returns random number' do
      expect(subject.job_id).not_to eq subject.job_id
    end
  end
end
