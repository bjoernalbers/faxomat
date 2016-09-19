class Report::Release < ActiveRecord::Base
  include Report::StatusChange
end
