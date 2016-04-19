# Only create real print jobs in production.
PrintJob.fake_printing = (Rails.env.production? ? false : true)
