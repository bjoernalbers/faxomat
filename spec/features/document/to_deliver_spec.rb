# In order to handle all undelivered documents
# As a user
# I want to see all to deliver documents.

feature 'To deliver documents' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'navigation' do
    visit root_url
    click_link 'Dokumente'
    click_link 'Zu senden'

    expect(current_path).to eq deliver_documents_path

    current_tab = nil
    within('#documents_nav') do
      current_tab = find('.active').text
    end
    expect(current_tab).to eq 'Zu senden'
  end

  scenario 'list' do
    document = create(:verified_report).document
    other = create(:pending_report).document

    visit documents_url
    click_link 'Zu senden'

    expect(page).to have_content(document.title)
    expect(page).not_to have_content(other.title)
  end
end
