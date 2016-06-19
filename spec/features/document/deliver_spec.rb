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
    document = create(:document, report: create(:pending_report))
    expect(document).not_to be_released_for_delivery

    visit document_url(document)

    expect(page).not_to have_button('Faxen')
  end

  scenario 'when deliverable' do
    document = create(:document, report: create(:verified_report))
    expect(document).to be_released_for_delivery

    visit document_url(document)

    expect {
      click_button 'Faxen'
    }.to change(PrintJob, :count).by(1)
  end

  scenario 'when deliverable but not faxable' do
    recipient = create(:recipient, fax_number: nil)
    document = create(:document, report: create(:verified_report), recipient: recipient)

    visit document_url(document)

    expect(page).not_to have_button('Faxen')
  end
end
