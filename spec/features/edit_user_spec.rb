# As a doctor / user
# I want to be able to change my profile by myself
# In order to not bother "the IT-guys" with this kind of stuff.

feature 'Edit user' do
  scenario 'change name' do
    user = create(:user,
                  first_name: 'Bjrn',
                  last_name:  'Albrs',
                  title:      nil,
                  password:   'totalgeheim')
    login_as user, scope: :user

    visit root_path
    click_link user.username

    #TODO: Add german translations!
    fill_in 'First name',       with: 'Björn'
    fill_in 'Last name',        with: 'Albers'
    fill_in 'Title',            with: 'Dipl.-Ing. (FH)'
    fill_in 'Current password', with: 'totalgeheim'
    click_button 'Update'

    user.reload
    expect(user.first_name).to eq 'Björn'
    expect(user.last_name).to  eq 'Albers'
    expect(user.title).to      eq 'Dipl.-Ing. (FH)'
  end

  scenario 'upload signature'
end
