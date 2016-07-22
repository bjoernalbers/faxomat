# As a user
# I want to see document delivery information
# In order to check it before sending it again

feature 'View document' do
  let(:user) { create(:user) }
  let(:document) { create(:document) }

  before do
    login_as user, scope: :user
  end

  scenario 'without deliveries' do
    visit document_url(document)

    expect(page).to have_content document.title
    expect(page).not_to have_content 'gesendet'
  end

  scenario 'with deliviveries' do
    print = create(:completed_print,
                       document: document,
                       created_at: '2016-05-25 12:42')

    visit document_url(document)

    expect(page).to have_content document.title
    expect(page).to have_content 'gesendet'

    expect(page).to have_content document.recipient.full_name

    expect(page).to have_content 'Mittwoch, 25. Mai 2016, 12:42 Uhr'
    expect(page).to have_content print.fax_number
    expect(page).to have_content 'erledigt'
    expect(page).to have_content print.printer.name
  end

  scenario 'download' do
    visit document_url(document)
    click_link 'Herunterladen'

    expect(page.response_headers['Content-Type']).to eq 'application/pdf'
  end
end
