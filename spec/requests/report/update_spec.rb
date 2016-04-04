describe 'PUT /api/reports/:id' do
  let(:user) { create(:user) }
  let!(:report) { create(:report) }

  def do_post
    put "/api/reports/#{report.id}", params, header
  end

  def json
    @json ||= JSON.parse(response.body, symbolize_names: true)
  end

  let(:header) do
    { 'Accept'       => nil, # Report API should return JSON by default.
      'Content-Type' => 'application/json' }
  end

  context 'with valid params' do
    let(:params) do
      username = create(:user).username
      attributes_for(:api_report).merge(username: username).to_json
    end

    it 'updates report' do
      old_findings = report.findings
      do_post
      report.reload
      expect(report.findings).not_to eq old_findings
    end

    it 'does not create new report in database' do
      expect { do_post }.to change(Report, :count).by(0)
    end

    it 'returns HTTP status 200' do
      do_post
      expect(response.status).to eq 200
    end

    it 'responds in JSON' do
      do_post
      expect(response.content_type).to be_json
      expect(json[:id]).to      eq Report.last.id
      expect(json[:message]).to eq 'Bericht erfolgreich aktualisiert'
      expect(json[:errors]).to  be nil
      expect(json[:pdf_url]).to eq api_report_url(Report.last, format: :pdf) # TODO: Remove!
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

    it 'responds in JSON' do
      do_post
      expect(response.content_type).to be_json
      expect(json[:id]).to      eq report.id
      expect(json[:message]).to eq 'Bericht ist fehlerhaft'
      expect(json[:errors]).to  be_a Array
      expect(json[:pdf_url]).to eq api_report_url(Report.last, format: :pdf) # TODO: Remove!
    end
  end
end
