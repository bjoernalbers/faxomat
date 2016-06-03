# In order to quickly check past deliveries
# as a user
# I want to search documents

feature 'Search documents' do
  let(:user) { create(:user) }
  let(:tab) { 'Suche' }

  before do
    login_as user, scope: :user
  end

  def visit_search_documents
    visit root_url
    click_link 'Versendungen'
    click_link tab
  end

  scenario 'navigation' do
    visit_search_documents

    expect(current_path).to eq search_documents_path

    within('#navbar') do
      expect(find('.active').text).to eq 'Versendungen'
    end

    within('#documents_nav') do
      expect(find('.active').text).to eq tab
    end
  end

  scenario 'document found' do
    document = create(:document, title: 'Norris, Chuck (* 10.3.1049)')

    visit_search_documents

    fill_in 'Titel', with: 'Norris'
    click_button 'Suchen'

    expect(page).to have_content(document.title)
  end

  scenario 'no documents found' do
    document = create(:document, title: 'Norris, Chuck (* 10.3.1049)')

    visit_search_documents

    fill_in 'Titel', with: 'asdf'
    click_button 'Suchen'

    expect(page).to have_content 'Nichts gefunden.'
    expect(page).not_to have_content(document.title)
  end
end
