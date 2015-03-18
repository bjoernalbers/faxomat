require 'spec_helper'

# In order to clean faxes that can not be delivered
# As a user
# I want to delete aborted faxes.

feature 'Delete faxes' do
  let(:app) { App.new }

  scenario 'when aborted' do
    page = app.aborted_faxes_page
    fax = create(:aborted_fax)

    page.load

    expect {
      click_link 'löschen'
    }.to change(Fax, :count).by(-1)
  end
end
