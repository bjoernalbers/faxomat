feature 'navigation' do
  scenario 'active faxes' do
    app = App.new

    visit '/'
    click_link 'Faxe in Versendung'

    expect(app.faxes_page).to be_displayed
  end

  scenario 'aborted faxes' do
    app = App.new

    visit '/'
    click_link 'Abgebrochene Faxe'

    expect(app.aborted_faxes_page).to be_displayed
  end
end
