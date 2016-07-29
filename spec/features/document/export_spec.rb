# As a user
# I want to export a document
# In order to easily share PDFs across departments.

feature 'Export document' do
  def click_new_export
    within '#exports_panel' do
      click_link 'Neu'
    end
  end

  scenario 'when not deliverable' do
    document = create(:document, report: create(:pending_report))
    expect(document).not_to be_released_for_delivery

    visit document_url(document)

    expect { click_new_export }.to raise_error(Capybara::ElementNotFound)
  end

  scenario 'when deliverable' do
    document = create(:document, report: create(:verified_report))
    directory = create(:directory)
    expect(document).to be_released_for_delivery

    visit document_url(document)

    expect {
      click_new_export
      select directory.description
      click_button 'Exportieren'
    }.to change(Export, :count).by(1)
    export = document.exports.last
    expect(page).to have_content(export.filename)
  end
end
