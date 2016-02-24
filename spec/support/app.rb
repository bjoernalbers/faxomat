class PrintJobSection < SitePrism::Section
  element :title, '.title'
  element :fax_number, '.fax_number'
  element :created_at, '.created_at'
  element :status, '.status'
end

class PrintJobsPage < SitePrism::Page
  set_url '/print_jobs'
  set_url_matcher /print_jobs\/?/

  sections :print_jobs, PrintJobSection, '.print_job'

  def has_print_job?(print_job)
    print_jobs.any? { |f| f.has_css?("#print_job_#{print_job.id}") }
  end
end

class AbortedPrintJobsPage < PrintJobsPage
  set_url '/print_jobs/aborted'
  set_url_matcher /print_jobs\/aborted\/?/
end

class SearchPrintJobsPage < PrintJobsPage
  set_url '/print_jobs/search{?title*}'
  set_url_matcher /print_jobs\/search\/?/
end

class App
  def print_jobs_page
    PrintJobsPage.new
  end

  def aborted_print_jobs_page
    AbortedPrintJobsPage.new
  end
end
