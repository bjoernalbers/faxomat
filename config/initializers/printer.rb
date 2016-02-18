# Only create real print jobs in production.
Printer.default_driver_class = Printer::TestDriver unless Rails.env.production?
