RSpec.configure do |config|
  # Make `view` available for presenter specs.
  config.include ActionView::TestCase::Behavior, file_path: %r{spec/presenters}
end
