describe DocumentsController do
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
