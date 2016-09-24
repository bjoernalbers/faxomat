# As aun unauthorized user
# I want to unsign pendings reports
# In order to be able to update a report again

feature 'Unsign Report' do
  scenario 'when pending' do
    user = create(:unauthorized_user)
    login_as user, scope: :user
    report = create(:verified_report, user: user)
    expect(report).not_to be_updatable

    visit report_url(report)
    click_link 'Vidierung löschen'

    report.reload
    expect(report).to be_updatable
    expect(current_path).to eq report_path(report)
  end

  scenario 'when released' do
    user = create(:unauthorized_user)
    login_as user, scope: :user
    report = create(:verified_report, user: user)
    create(:report_release, report: report)

    visit report_url(report)
    expect(page).not_to have_content('Vidierung löschen')
  end

  scenario 'when signed by other user' do
    user = create(:unauthorized_user)
    other = create(:unauthorized_user)
    login_as user, scope: :user
    report = create(:verified_report, user: other)

    visit report_url(report)
    expect(page).not_to have_content('Vidierung löschen')
  end
end
