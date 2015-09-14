# As a doctor / user
# I want to be able to login as myself with username & password
# In order to restrict access to sensitive patient data.

feature 'Authentication' do
  scenario 'with valid credentials' do
    user = create(:user, username: 'why', password: 'chunkybacon')

    visit root_url
    click_link 'Anmelden'
    #TODO: Add german translations!
    #fill_in 'Benutzername', with: user.username
    fill_in 'Username', with: user.username
    #fill_in 'Passwort', with: user.password
    fill_in 'Password', with: user.password
    #click_button 'Anmelden'
    click_button 'Log in'

    expect(page).to have_content 'Arztbriefe'

    click_link 'why abmelden'

    expect(page).not_to have_content 'Arztbriefe'
  end
end
