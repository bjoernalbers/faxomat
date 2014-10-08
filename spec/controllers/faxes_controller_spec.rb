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

    it 'assigns only today created faxes' do
      today = create(:fax)
      yesterday = create(:fax, created_at: today.created_at-1.day)

      get :index

      expect(assigns(:faxes)).to eq [today]
    end
  end

  describe 'GET show' do
    it 'sends the pdf document' do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      controller.stub!(:render)

      fax = create(:fax)
      controller.should_receive(:send_file).
        with(fax.document.path, type: 'application/pdf', disposition: 'inline')
      get :show, id: fax
    end
  end

  describe 'GET aborted' do
    let(:fax) { create(:fax) }

    before do
      allow(Fax).to receive(:aborted) { [fax] }
    end

    it 'assigns aborted faxes' do
      get :aborted
      expect(assigns(:faxes)).to match_array([fax])
    end

    it 'fetches all aborted faxes through the model' do
      get :aborted
      expect(Fax).to have_received(:aborted)
    end

    it 'renders the index template' do
      get :aborted
      expect(response).to render_template(:index)
    end
  end
end
