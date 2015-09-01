describe 'POST /api/reports' do
  let(:user) { build(:user) }
  let(:header) do
    { 'Accept'       => nil, # Report API should return JSON by default.
      'Content-Type' => 'application/json' }
  end

  def do_post
    post '/api/reports', params, header
  end

  def body
    @body ||= JSON.parse(response.body, symbolize_names: true)
  end

  context 'with valid params' do
    let(:params) do
      { subject: Faker::Lorem.sentence,
        content: Faker::Lorem.sentences.join("\n"),
        username: user.username }.to_json
    end

    it 'creates report in database' do
      expect { do_post }.to change(Report, :count).by(1)
    end

    it 'returns HTTP status 201' do
      do_post
      expect(response.body).to eq 'foo'#debug
      expect(response.status).to eq 201
    end

    it 'returns JSON' do
      do_post
      expect(response.content_type).to be_json
    end

    it 'returns report id' do
      pending 'add method to return pdf_url!'
      do_post
      expect(body[:id]).to eq Report.last.id
      expect(body[:pdf_url]).to eq pdf_report_url(Report.last)
    end

    it 'includes resource URL in location header' do
      do_post
      expect(response.location).to eq api_report_url(Report.last)
    end
  end

  context 'with invalid params' do
    let(:params) do
      { subject: Faker::Lorem.sentence,
        content: Faker::Lorem.sentences.join("\n"),
        username: nil }.to_json
    end

    it 'creates no report' do
      expect { do_post }.to change(Report, :count).by(0)
    end

    it 'returns HTTP status 422' do
      do_post
      expect(response.status).to eq 422
    end

    it 'returns JSON' do
      do_post
      expect(response.content_type).to be_json
    end

    it 'returns array of errors' do
      do_post
      expect(body[:errors]).to be_present
      expect(body[:errors]).to be_a(Array)
    end
  end
end
