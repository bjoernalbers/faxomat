# In order to ensure that every report gets verified
# as a user
# I want to see all pending reports.

feature 'Pending reports list' do
  let(:user) { create(:user) }
  let(:pending_tab) { 'Unvidiert' }

  before do
    login_as user, scope: :user
  end

  def visit_pending_reports
    visit root_url
    click_link 'Arztbriefe'
    click_link pending_tab
  end

  scenario 'navigation' do
    visit_pending_reports

    expect(current_path).to eq reports_path
    within('#navbar') do
      expect(find('.active').text).to eq 'Arztbriefe'
    end
    within('#reports_nav') do
      expect(find('.active').text).to eq pending_tab
    end
  end

  scenario 'content'
end
