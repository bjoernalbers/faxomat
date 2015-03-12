require 'spec_helper'

describe 'Create Fax' do
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

    it 'creates a new fax' do
      expect{ do_post }.to change(Fax, :count).by(1)
    end

    it 'saves the content' do
      do_post
      fax = Fax.first
      expect(File.read(fax.document.path)).to eq File.read(path)
      #expect(Fax.count).to eq 1
      #expect(Fax.first.document.path).to_not be_nil
    end

    it 'delivers fax' do
      fax = double(:fax, save: true, deliver: nil)
      allow(Fax).to receive(:new).and_return(fax)
      do_post
      expect(fax).to have_received(:deliver)
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

    it 'returns the validation errors' do
      fax = Fax.new
      fax.valid? # Used to populate the errors
      post '/faxes', params, headers
      expect(response.body).to eq fax.errors.to_json
    end
  end
end
