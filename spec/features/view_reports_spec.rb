# As a doctor / user
# I want to view only my own reports
# In order to not get distracted and focus on my work.

include Warden::Test::Helpers
Warden.test_mode!

feature 'View Reports' do
  scenario 'happy path' do
    user = create(:user)

    report = create(:report, user: user)
    other = create(:report)

    login_as user, scope: :user

    visit reports_path

    expect(page).to have_content('Arztbriefe')

    expect(page).to have_content(report.title)
    expect(page).not_to have_content(other.title)

    click_link report.title

    expect(page).to have_content(report.content)

    # go back
    #
    # visit show url of other report (directly)
    # expect some error message (404 or forbidden?)
    #
  end
end
