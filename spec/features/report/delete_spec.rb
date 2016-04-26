# As a doctor / user
# I want to delete reports
# In order to remove duplicates.

feature 'Delete report' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'when pending' do
    report = create(:pending_report, user: user)
    expect {
      visit report_url(report)
      click_button 'Löschen'
    }.to change(Report, :count).by(-1)
    expect(current_url).to eq reports_url
    expect(page).to have_content 'Der Arztbrief wurde gelöscht.'
  end

  scenario 'when from other user' do
    report = create(:pending_report)
    visit report_url(report)
    expect(page).not_to have_button 'Löschen'
  end

  scenario 'when not logged in' do
    report = create(:pending_report, user: user)
    logout(:user)
    visit report_url(report)
    expect(page).not_to have_button 'Löschen'
  end

  scenario 'when verified' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    expect(page).not_to have_button 'Löschen'
  end

  scenario 'when canceled' do
    report = create(:canceled_report, user: user)
    visit report_url(report)
    expect(page).not_to have_button 'Löschen'
  end
end
