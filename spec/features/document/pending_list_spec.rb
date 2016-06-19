# In order to ensure that every document gets successfully delivered
# as a user
# I want to see all pending documents.

feature 'Pending documents list' do
  let(:user) { create(:user) }
  let(:pending_tab) { 'Unerledigt' }

  before do
    login_as user, scope: :user
  end

  def visit_pending_documents
    visit root_url
    click_link 'Versendungen'
    #click_link 'Zu senden' # todo: Rename to "Unerledgit":
    click_link pending_tab
  end

  scenario 'navigation' do
    visit_pending_documents

    expect(current_path).to eq deliver_documents_path
    within('#navbar') do
      expect(find('.active').text).to eq 'Versendungen'
    end
    within('#documents_nav') do
      #expect(find('.active').text).to eq 'Unerledigt' # TODO: REname to "Unerledigt"!
      expect(find('.active').text).to eq pending_tab
    end
  end

  scenario 'content' do
    verified_report = create(:verified_report)
    pending_report = create(:pending_report)
    document = create(:document, report: verified_report)
    other = create(:document, report: pending_report)

    visit_pending_documents

    expect(page).to have_content(document.title)
    expect(page).not_to have_content(other.title)
  end
end
