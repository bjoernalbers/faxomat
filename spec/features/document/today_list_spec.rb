# In order to quickly check and access recent deliveries
# as a user
# I want to list all documents with todays deliveries.

feature 'Todays doocuments list' do
  let(:user) { create(:user) }
  let(:today_tab) { 'Heute' }

  before do
    login_as user, scope: :user
  end

  def visit_todays_documents
    visit root_url
    click_link 'Versendungen'
  end

  scenario 'navigation' do
    visit_todays_documents

    expect(current_path).to eq documents_path

    within('#navbar') do
      expect(find('.active').text).to eq 'Versendungen'
    end

    expect(page).to have_link today_tab
    within('#documents_nav') do
      expect(find('.active').text).to eq today_tab
    end
  end

  scenario 'without documents' do
    visit_todays_documents
    expect(page).to have_content 'Heute wurde noch nichts versendet.'
  end

  scenario 'undelivered document' do
    document = create(:document)
    create(:aborted_print_job, document: document)

    visit_todays_documents

    expect(page).to have_content(document.title)
    expect(page).not_to have_content('gesendet')
  end

  scenario 'delivered document' do
    document = create(:document)
    create(:completed_print_job, document: document)

    visit documents_url

    expect(page).to have_content(document.title)
    expect(page).to have_content('gesendet')
  end
end
