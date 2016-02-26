describe 'Create fax' do
  let(:path) do
    File.join(File.dirname(__FILE__), '..', 'support', 'sample.pdf')
  end
  let(:mime_type) { 'application/pdf' }

  let(:headers) do
    {
      'Accept'       => 'application/json',
      #'Content-Type' => 'application/json'
    }
  end

  before do
    Rails.application.load_seed # To make the fax printer available!
  end

  context 'with valid params' do
    let(:params) do
      {
        fax: {
          phone:    '013456789',
          title:    'hello, world!',
          document: Rack::Test::UploadedFile.new(path, mime_type)
        }
      }
    end

    def do_post
      post '/faxes', params, headers
    end

    it 'responds with HTTP 201' do
      do_post
      expect( response.status ).to eq 201
    end

    it 'returns the fax as JSON'

    it 'responds in JSON' do
      do_post
      expect( response.content_type ).to be_json
    end

    it 'creates a new print job' do
      expect{ do_post }.to change(Printer.fax_printer.print_jobs, :count).by(1)
    end

    it 'saves the content' do
      do_post
      print_job = Printer.fax_printer.print_jobs.first
      expect(File.read(print_job.document.path)).to eq File.read(path)
    end
  end

  context 'with invalid params' do
    let(:params) do
      {
        fax: {
          phone: nil,
          document: nil
        }
      }
    end

    it 'responds with HTTP 422' do
      post '/faxes', params, headers
      expect( response.status ).to eq 422
    end

    it 'responds in JSON' do
      post '/faxes', params, headers
      expect( response.content_type ).to be_json
    end
  end
end
