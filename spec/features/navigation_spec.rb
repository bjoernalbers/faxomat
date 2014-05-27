require 'spec_helper'

feature 'navigation' do
  scenario 'all faxes' do
    app = App.new

    visit '/'
    click_link 'Heutige Faxe'

    expect(app.faxes_page).to be_displayed
  end

  scenario 'aborted faxes' do
    app = App.new

    visit '/'
    click_link 'Abgebrochene Faxe'

    expect(app.aborted_faxes_page).to be_displayed
  end
end
