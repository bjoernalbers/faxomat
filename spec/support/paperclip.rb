require 'paperclip/matchers'

# Include paperclip shoulda matchers
# See: http://www.rubydoc.info/gems/paperclip/Paperclip/Shoulda/Matchers
RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end
