module API
  describe Report do
    let(:report) { Report.new }

    it 'has valid factory' do
      report = build(:api_report)
      expect(report).to be_valid
    end

    # Required attributes
    [
      :subject,
      :content,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth
    ].each do |attr|
      it { expect(report).to validate_presence_of(attr) }
    end

    it 'validates existence of username' do
      report.username = 'thisuserdoesnotexist'
      expect(report).to be_invalid
      expect(report.errors[:username]).to be_present
    end

    it 'saves report' do
      report = build(:api_report)
      expect{report.save}.to change(::Report, :count).by(1)
    end

    describe '#id' do
      it 'gets delegated to ::Report#id' do
        allow(report).to receive(:report).and_return( double(id: 42) )
        expect(report.id).to eq 42
      end
    end
  end
end
