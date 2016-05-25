# As a user
# I want to see document delivery information
# In order to check it before sending it again

feature 'View document' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'without deliveries' do
    document = create(:document)

    visit document_url(document)

    expect(page).to have_content document.title
    expect(page).to have_content 'ungesendet'
  end

  scenario 'with deliviveries' do
    document = create(:document)
    print_job = create(:completed_print_job, document: document, created_at: '2016-05-25 12:42')

    visit document_url(document)

    expect(page).to have_content document.title
    expect(page).not_to have_content 'ungesendet'
    expect(page).to have_content 'gesendet'
    expect(page).to have_content 'Mittwoch, 25. Mai 2016, 12:42 Uhr'
    expect(page).to have_content print_job.fax_number
    expect(page).to have_content 'erledigt'
    expect(page).to have_content print_job.printer.name
  end

  scenario 'download' do
    document = create(:document)

    visit document_url(document)
    click_link 'Herunterladen'

    expect(page.response_headers['Content-Type']).to eq 'application/pdf'
  end
end
