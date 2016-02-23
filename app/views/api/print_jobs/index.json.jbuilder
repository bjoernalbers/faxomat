json.extract!(@print_jobs.count_by_status, :completed, :aborted, :active)
