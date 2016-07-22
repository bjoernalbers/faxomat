# Only create real print jobs in production.
Print.fake_printing = (Rails.env.production? ? false : true)
