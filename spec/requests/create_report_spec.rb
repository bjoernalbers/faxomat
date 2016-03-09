describe 'POST /api/reports' do
  def do_post
    post '/api/reports', params, header
  end

  def json
    @json ||= JSON.parse(response.body, symbolize_names: true)
  end

  let(:user) { create(:user) }

  let(:header) do
    { 'Accept'       => nil, # Report API should return JSON by default.
      'Content-Type' => 'application/json' }
  end

  context 'with valid params' do
    let(:params) do
      username = create(:user).username
      attributes_for(:api_report).merge(username: username).to_json
    end

    it 'creates report in database' do
      expect { do_post }.to change(Report, :count).by(1)
    end

    it 'returns HTTP status 201' do
      do_post
      expect(response.status).to eq 201
    end

    it 'returns JSON' do
      do_post
      expect(response.content_type).to be_json
    end

    it 'returns report id' do
      do_post
      expect(json[:id]).to eq Report.last.id
      expect(json[:pdf_url]).to eq api_report_url(Report.last, format: :pdf)
    end

    it 'includes resource URL in location header' do
      do_post
      expect(response.location).to eq api_report_url(Report.last)
    end
  end

  context 'with invalid params' do
    let(:params) do
      attributes_for(:api_report).to_json
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
      expect(json[:errors]).to be_present
      expect(json[:errors]).to be_a(Array)
    end
  end

  context 'without recipient fax number' do
    let(:params) do
      username = create(:user).username
      attributes_for(:api_report, recipient_fax_number: nil).
        merge(username: username).to_json
    end

    it 'creates report in database' do
      expect { do_post }.to change(Report, :count).by(1)
    end
  end
end
