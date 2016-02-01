# As a user
# I want to delete accidentially created reports
# In order to not get distracted by them

feature 'Delete reports' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'when pending' do
    report = create(:pending_report, user: user)
    visit report_url(report)

    expect {
      click_button 'Löschen'
    }.to change(Report, :count).by(-1)

    expect(current_url).to eq reports_url
    expect(page).to have_content('wurde gelöscht')
  end

  scenario 'when verified' do
    report = create(:verified_report, user: user)
    visit report_url(report)

    expect(page).not_to have_button 'Löschen'
  end
end
