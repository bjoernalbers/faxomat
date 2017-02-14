# As a doctor / user
# I want to cancel reports
# In order to avoid that invalid reports gets accidentially send.

feature 'Cancel report' do
  let(:patient) { create(:patient) }

  scenario 'when verified' do
    user = create(:user)
    report = create(:verified_report, user: user, patient: patient)
    login_as user, scope: :user

    visit report_url(report)
    expect(page).not_to have_content 'Storniert'
    click_button 'Stornieren'
    expect(current_url).to eq reports_url
    visit report_url(report)
    expect(page).not_to have_button 'Stornieren'
    expect(page).to have_content 'Storniert'

    report.reload
    expect(report).to be_canceled
  end

  scenario 'when from unauthorized user' do
    user = create(:unauthorized_user)
    report = create(:verified_report, user: user, patient: patient)
    Report::Verification.
      new(report: report, user: create(:authorized_user)).save

    login_as user, scope: :user

    visit report_url(report)
    expect(page).not_to have_content 'Storniert'
    click_button 'Stornieren'
    visit report_url(report)
    expect(page).not_to have_button 'Stornieren'
    expect(page).to have_content 'Storniert'

    report.reload
    expect(report).to be_canceled
  end

  scenario 'when from other user' do
    user = create(:user)
    other = create(:user)
    report = create(:verified_report, user: user, patient: patient)

    login_as other, scope: :user
    visit report_url(report)
    expect(page).not_to have_button 'Stornieren'
  end
end
