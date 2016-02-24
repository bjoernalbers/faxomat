# In order know what is currently being delivered (or not)
# As a user
# I want to view print jobs

feature 'View print jobs' do
  let(:app) { App.new }

  scenario 'when aborted' do
    page = app.aborted_print_jobs_page
    print_job = create(:aborted_print_job)

    page.load

    expect(page.print_jobs.count).to eq 1
    print_job_section = page.print_jobs.first
    expect(print_job_section.title.text).to eq(print_job.title)
    expect(print_job_section.fax_number.text).to eq(print_job.fax_number)
    expect(print_job_section.status.text).to eq('aborted')
    expect(print_job_section).to have_css('.aborted')
  end

  scenario 'when active' do
    page = app.print_jobs_page
    print_job = create(:active_print_job)

    page.load

    expect(page.print_jobs.count).to eq 1
    print_job_section = page.print_jobs.first
    expect(print_job_section.title.text).to eq(print_job.title)
    expect(print_job_section.fax_number.text).to eq(print_job.fax_number)
    expect(print_job_section.status.text).to eq('active')
    expect(print_job_section).to have_css('.active')
  end
end
