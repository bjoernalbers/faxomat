class User < ActiveRecord::Base
  has_many :reports

  validates :username,
    presence: true,
    uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable
  # :trackable, :recoverable, :validatable
  devise :database_authenticatable, :registerable, :rememberable

  # Return display name.
  def name
    full_name.present? ? full_name : username
  end

  private

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end
end
