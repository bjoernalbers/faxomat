# As a user
# I want to deliver a document
# because thats the main feature of faxomat :-)

feature 'Deliver document' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
    Rails.application.load_seed # To make the fax printer available! 
  end

  scenario 'when not deliverable' do
    document = create(:pending_report).document
    expect(document).not_to be_released_for_delivery

    visit document_url(document)

    expect(page).not_to have_button('Faxen')
  end

  scenario 'when deliverable' do
    document = create(:verified_report).document
    expect(document).to be_released_for_delivery

    visit document_url(document)

    expect {
      click_button 'Faxen'
    }.to change(PrintJob, :count).by(1)
  end
end
