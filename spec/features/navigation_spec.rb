require 'spec_helper'

feature 'navigation' do
  scenario 'todays faxes' do
    app = App.new

    visit '/'
    click_link 'Heute'

    expect(app.faxes_page).to be_displayed
  end

  scenario 'undeliverable faxes' do
    app = App.new

    visit '/'
    click_link 'Unzustellbar'

    expect(app.undeliverable_faxes_page).to be_displayed
  end
end
