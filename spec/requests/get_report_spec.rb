describe 'GET /api/reports/:id' do
  def json(body)
    @json ||= JSON.parse(body, symbolize_names: true)
  end

  let(:report) { create(:report) }

  before do
    get "/api/reports/#{report.id}", { }, header
  end

  context 'without Accept header' do
    let(:header) do
      {
        'Accept'       => nil,
        'Content-Type' => 'application/json'
      }
    end

    it 'returns HTTP status 200' do
      expect(response.status).to eq 200
    end

    it 'returns content type JSON' do
      expect(response.content_type).to be_json
    end

    #it 'returns report id' do
      #pending 'add method to return pdf_url!'
      #do_post
      #expect(body[:id]).to eq Report.last.id
      #expect(body[:pdf_url]).to eq pdf_report_url(Report.last)
    #end

    it 'includes resource URL in location header' do
      expect(response.location).to eq api_report_url(Report.last)
    end
  end

  context 'with Accept header "application/pdf"' do
    let(:header) do
      {
        'Accept'       => 'application/pdf',
        'Content-Type' => 'application/json'
      }
    end

    it 'returns HTTP status 200' do
      expect(response.status).to eq 200
    end

    it 'returns content type PDF' do
      expect(response.content_type).to be_pdf
    end

    it 'sends report as PDF' do
      expect(response.body[0,4]).to eq('%PDF')
    end
  end
end
