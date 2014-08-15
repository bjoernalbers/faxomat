require 'spec_helper'

describe 'Create Fax' do
  let(:headers) do
    {
      'Accept'       => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  context 'with valid params' do
    let(:params) do
      {
        fax: {
          path: '/tmp/hello.pdf',
          recipient_attributes: {
            phone: '0123456789'
          },
          patient_attributes: {
            first_name: 'Chuck',
            last_name: 'Norris',
            date_of_birth: '1940-03-10'
          }
        }
      }.to_json
    end

    def do_post
      post '/faxes', params, headers
    end

    it 'responds with HTTP 201' do
      do_post
      expect( response.status ).to eq 201
    end

    it 'responds in JSON' do
      do_post
      expect( response.content_type ).to be_json
    end

    it 'creates a new fax' do
      expect{ do_post }.to change(Fax, :count).by(1)
    end
  end

  context 'with invalid params' do
    let(:params) do
      { fax: { path: nil } }.to_json
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
      post '/faxes', {fax: {path: nil}}.to_json, headers
      expect(response.body).to eq fax.errors.to_json
    end
  end
end
