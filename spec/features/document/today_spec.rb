# In order to quickly check if delivery is working
# And to access recent documents
# As a user
# I want to see all today created documents.

feature 'Today documents' do
  let!(:document) { create(:document) }
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'navigation' do
    visit root_url
    click_link 'Dokumente'

    expect(current_path).to eq documents_path

    current_tab = nil
    within('#documents_nav') do
      current_tab = find('.active').text
    end
    expect(current_tab).to eq 'Heute'
  end

  scenario 'without documents' do
    document.destroy!
    visit documents_url
    expect(page).to have_content 'Heute wurde noch kein Dokument angelegt.'
  end

  scenario 'undelivered document' do
    visit documents_url

    expect(page).to have_content(document.title)
    expect(page).not_to have_content('gesendet')
  end

  scenario 'delivered document' do
    create(:completed_print_job, document: document)
    visit documents_url

    expect(page).to have_content(document.title)
    expect(page).to have_content('gesendet')
  end
end
