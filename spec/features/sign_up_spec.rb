# As a doctor / user
# I want to sign up with my username and password
# In order to be able to login as myself.

feature 'Sign up' do
  scenario 'new user' do
    visit new_user_registration_path

    #TODO: Add german translations!

    expect(page).to have_content('Sign up')

    fill_in 'Username',              with: 'bjoern'
    fill_in 'First name',            with: 'Björn'
    fill_in 'Last name',             with: 'Albers'
    fill_in 'Title',                 with: 'Dipl.-Ing. (FH)'
    fill_in 'Password',              with: 'totalgeheim'
    fill_in 'Password confirmation', with: 'totalgeheim'

    #TODO: Test upload of signature image!

    click_button 'Sign up'

    user = User.find_by username: 'bjoern'
    expect(user.first_name).to eq 'Björn'
    expect(user.last_name).to  eq 'Albers'
    expect(user.title).to      eq 'Dipl.-Ing. (FH)'

    # TODO: Check that we're on the user's root page.
    expect(page).to have_content 'Sie haben sich erfolgreich registriert.'
  end
end
