# As a business owner
# I want to customize my templates
# So that reports include my name and stuff

feature 'Template' do
  let(:user) { create(:user) }

  scenario 'when missing' do
    pending 'fix null object behaviour'
    login_as user, scope: :user
    template = FactoryGirl.build(:template)
    expect(Template.count).to be_zero
    expect {
      visit template_path
      click_link 'Neue Vorlage erstellen'
      fill_in 'Title', with: template.title
      # TODO: Test logo upload!
      click_button 'Vorlage erstellen'
    }.to change(Template, :count).by(1)
    expect(page).to have_content template.title
    # TODO: Test other attributes as well!
  end

  scenario 'when present' do
    login_as user, scope: :user
    template = FactoryGirl.create(:template)
    new_title = FactoryGirl.build(:template).title

    visit template_path
    expect(page).to have_content template.title
    expect(page).not_to have_content new_title
    
    click_link 'Vorlage bearbeiten'
    fill_in 'Title', with: new_title
    click_button 'Vorlage aktualisieren'

    expect(page).not_to have_content template.title
    expect(page).to have_content new_title
  end

  scenario 'when not logged in' do
    visit template_path
    expect(current_path).to eq new_user_session_path
  end
end
