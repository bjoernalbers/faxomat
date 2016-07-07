class User < ActiveRecord::Base
  has_many :reports

  validates :username,   presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name,  presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable
  # :trackable, :recoverable, :validatable
  devise :database_authenticatable, :registerable, :rememberable

  has_attached_file :signature,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'
  validates_attachment :signature,
    content_type: { content_type: %w(image/jpg image/jpeg image/png) },
    size:         { in: 0..30.kilobytes }

  # Return display name.
  def name
    full_name.present? ? full_name : username
  end

  def full_name
    [title, first_name, last_name].select(&:present?).join(' ')
  end

  def signature_path
    signature.path if signature.present?
  end
end
