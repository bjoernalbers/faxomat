class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable
  # :trackable, :recoverable, :validatable
  devise :database_authenticatable, :registerable, :rememberable

  validates :username,
    presence: true,
    uniqueness: true

  # Return display name.
  def name
    full_name.present? ? full_name : username
  end

  private

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end
end
