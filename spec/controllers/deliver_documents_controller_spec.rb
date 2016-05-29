describe DeliverDocumentsController do
  describe 'GET #index' do
    let(:documents) { [ build(:document) ] }

    before do
      allow(Document).to receive(:to_deliver).and_return(documents)
      get :index
    end

    it 'renders index template' do
      expect(response).to render_template('documents/index')
    end

    it 'assigns documents' do
      expect(assigns(:documents)).to eq documents
    end

    it 'responds with success' do
      expect(response).to be_success
    end
  end
end
