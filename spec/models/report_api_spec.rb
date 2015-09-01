describe ReportApi do
  let(:report_api) { ReportApi.new }

  # Required attributes
  [ :subject, :content, :username ].each do |attr|
    it { expect(report_api).to validate_presence_of(attr) }
  end

  it 'validates existence of username' do
    report_api.username = 'thisuserdoesnotexist'
    expect(report_api).to be_invalid
    expect(report_api.errors[:username]).to be_present
  end

  it 'saves report' do
    user = create(:user)
    report_api = ReportApi.new(subject: 'test', content: 'some stuff', username: user.username)
    expect{report_api.save}.to change(Report, :count).by(1)
  end
end
