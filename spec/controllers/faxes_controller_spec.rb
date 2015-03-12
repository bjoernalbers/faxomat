require 'spec_helper'

describe FaxesController do
  describe 'GET index' do
    it 'assigns recipients faxes' do
      recipient = create(:recipient)
      fax = create(:fax, recipient: recipient)
      get :index, recipient_id: recipient
      expect(assigns(:faxes)).to eq [fax]
    end

    it 'does not assign faxes from other recipients' do
      recipient = create(:recipient)
      other_recipient = create(:recipient)
      fax = create(:fax, recipient: other_recipient)
      get :index, recipient_id: recipient
      expect(assigns(:faxes)).to_not include fax
    end

    it 'assigns only today updated faxes' do
      allow(Fax).to receive(:updated_today)
      get :index
      expect(Fax).to have_received(:updated_today)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'redirects to faxes'
      it 'returns successfully created'
      it 'saves fax'
    end

    context 'with invalid params' do
      it 'renders new template' do
        post :create, fax: attributes_for(:fax, title: nil)
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET show' do
    it 'sends the pdf document' do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      allow(controller).to receive(:render)

      fax = create(:fax)
      expect(controller).to receive(:send_file).
        with(fax.document.path, type: 'application/pdf', disposition: 'inline')
      get :show, id: fax
    end
  end

#  describe 'GET undeliverable' do
#    let(:fax) { create(:fax) }
#
#    before do
#      allow(Fax).to receive(:undeliverable) { [fax] }
#      get :undeliverable
#    end
#
#    it 'assigns undeliverable faxes' do
#      expect(assigns(:faxes)).to match_array([fax])
#    end
#
#    it 'fetches all aborted faxes through the model' do
#      expect(Fax).to have_received(:undeliverable)
#    end
#
#    it 'renders the index template' do
#      expect(response).to render_template(:index)
#    end
#  end
end
