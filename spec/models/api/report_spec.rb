module API
  describe Report do
    let(:report) { Report.new }

    # Required attributes
    [ :subject, :content, :username ].each do |attr|
      it { expect(report).to validate_presence_of(attr) }
    end

    it 'validates existence of username' do
      report.username = 'thisuserdoesnotexist'
      expect(report).to be_invalid
      expect(report.errors[:username]).to be_present
    end

    it 'saves report' do
      user = create(:user)
      report = Report.new(subject: 'test', content: 'some stuff', username: user.username)
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
