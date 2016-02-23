# In order to find older print jobs
# As a user with maaaaaaaaannny print jobs
# I want to be able to search them

feature 'Search print jobs' do
  scenario 'by title' do
    print_job = create(:print_job, title: 'My SWEET litle print job')
    other_print_job = create(:print_job, title: 'another boring one')

    page = SearchPrintJobsPage.new
    page.load(title: 'sweet')
    #page.load(q: '')

    expect(page).to have_print_job(print_job)
    expect(page).to_not have_print_job(other_print_job)
    expect(page.print_jobs.size).to eq 1
  end
end
