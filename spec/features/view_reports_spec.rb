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

    expect(page).to have_content('Betreff')
    expect(page).to have_content(report.subject)

    expect(page).to have_content('Untersuchung')
    expect(page).to have_content(report.examination)

    expect(page).to have_content('Anamnese')
    expect(page).to have_content(report.anamnesis)

    expect(page).to have_content('Diagnose')
    expect(page).to have_content(report.diagnosis)

    expect(page).to have_content('Befund')
    expect(page).to have_content(report.findings)

    expect(page).to have_content('Beurteilung')
    expect(page).to have_content(report.evaluation)

    expect(page).to have_content('Methode')
    expect(page).to have_content(report.procedure)

    # go back
    #
    # visit show url of other report (directly)
    # expect some error message (404 or forbidden?)
    #
  end
end
