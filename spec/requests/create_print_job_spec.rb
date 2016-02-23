describe 'Create Print job' do
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

  context 'with valid params' do
    let(:params) do
      {
        print_job: {
          phone:    '013456789',
          title:    'hello, world!',
          document: Rack::Test::UploadedFile.new(path, mime_type)
        }
      }
    end

    def do_post
      post '/print_jobs', params, headers
    end

    it 'responds with HTTP 201' do
      do_post
      expect( response.status ).to eq 201
    end

    it 'returns the print job as JSON'

    it 'responds in JSON' do
      do_post
      expect( response.content_type ).to be_json
    end

    it 'creates a new print job' do
      expect{ do_post }.to change(PrintJob, :count).by(1)
    end

    it 'saves the content' do
      do_post
      print_job = PrintJob.first
      expect(File.read(print_job.document.path)).to eq File.read(path)
    end
  end

  context 'with invalid params' do
    let(:params) do
      {
        print_job: {
          phone: nil,
          document: nil
        }
      }
    end

    it 'responds with HTTP 422' do
      post '/print_jobs', params, headers
      expect( response.status ).to eq 422
    end

    it 'responds in JSON' do
      post '/print_jobs', params, headers
      expect( response.content_type ).to be_json
    end

    it 'returns the validation errors' do
      print_job = PrintJob.new
      print_job.valid? # Used to populate the errors
      post '/print_jobs', params, headers
      expect(response.body).to eq print_job.errors.to_json
    end
  end
end
