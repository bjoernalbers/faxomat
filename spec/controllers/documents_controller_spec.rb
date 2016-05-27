describe DocumentsController do
  describe 'GET #index' do
    let(:documents) { [ build(:document) ] }

    before do
      allow(Document).to receive(:created_today).and_return(documents)
      get :index
    end

    it 'renders index template' do
      expect(response).to render_template('index')
    end

    it 'assigns documents' do
      expect(assigns(:documents)).to eq documents
    end

    it 'responds with success' do
      expect(response).to be_success
    end
  end

  describe 'GET #download' do
    let!(:document) { create(:document) }

    before do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      allow(controller).to receive(:render)

      allow(controller).to receive(:send_file)
    end

    it 'sends document' do
      get :download, id: document
      expect(controller).to have_received(:send_file).
        with(document.path, type: 'application/pdf')
    end
  end
end
