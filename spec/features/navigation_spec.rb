feature 'navigation' do
  scenario 'active print jobs' do
    app = App.new

    visit '/'
    click_link 'Aktive Druckaufträge'

    expect(app.print_jobs_page).to be_displayed
  end

  scenario 'aborted print jobs' do
    app = App.new

    visit '/'
    click_link 'Abgebrochene Druckaufträge'

    expect(app.aborted_print_jobs_page).to be_displayed
  end
end
