describe ReportsController do
  def current_user
    subject.current_user
  end

  # NOTE: Taken from...
  # https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-%28and-RSpec%29
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end

  describe 'DELETE #destroy' do
    def do_delete
      delete :destroy, id: report
    end

    context 'with pending report' do
      let!(:report) { create(:pending_report) }

      it 'destroys report' do
        expect {
          do_delete
        }.to change(Report, :count).by(-1)
      end

      it 'redirects to reports URL' do
        do_delete
        expect(response).to redirect_to reports_url
      end

      it 'sets flash notice' do
        do_delete
        expect(flash[:notice]).to eq 'Der Arztbrief wurde gelöscht.'
      end
    end

    context 'with verified report' do
      let!(:report) { create(:verified_report) }

      it 'does not destroy report' do
        expect {
          do_delete
        }.to change(Report, :count).by(0)
      end

      it 'renders report URL' do
        do_delete
        expect(response).to redirect_to report_url(report)
      end

      it 'sets flash error' do
        do_delete
        expect(flash[:alert]).not_to be nil
      end
    end
  end
end
