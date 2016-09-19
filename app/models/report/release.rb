class Report::Release < ActiveRecord::Base
  include Report::StatusChange

  acts_as_paranoid
end
