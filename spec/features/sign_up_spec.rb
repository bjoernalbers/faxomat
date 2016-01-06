# As a doctor / user
# I want to sign up with my username and password
# In order to be able to login as myself.

feature 'Sign up' do
  scenario 'new user' do
    user = build(:user, password: 'chunkybacon')

    visit new_user_registration_path

    #TODO: Add german translations!

    expect(page).to have_content('Sign up')

    fill_in 'Username', with: user.username
    fill_in 'First name', with: user.first_name
    fill_in 'Last name', with: user.last_name
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password

    #TODO: Test upload of signature image!

    click_button 'Sign up'

    #TODO: Test if user was persisted(?)!

    # TODO: Check that we're on the user's root page.
    expect(page).to have_content 'Sie haben sich erfolgreich registriert.'
  end
end
