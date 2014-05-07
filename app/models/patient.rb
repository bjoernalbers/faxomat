class Patient < ActiveRecord::Base
  has_many :faxes

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  before_validation :clean_name

  def info
    format('%s, %s (*%s)', last_name, first_name, date_of_birth)
  end

  private

  def clean_name
    [:first_name, :last_name].each do |attr|
      self[attr]= self[attr].strip.capitalize if self[attr]
    end
  end
end
