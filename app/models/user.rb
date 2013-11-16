class User < ActiveRecord::Base
  
  attr_accessible :email, :name, 
  :password, :password_confirmation,
  :owner, :owner_id, :admin, :provider, :uid
  has_paper_trail
  
  has_secure_password
  before_save { |user| user.email = email.downcase if email } 
  before_save :create_remember_token

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, format: {with: EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: 6}
  validates :password_confirmation, presence: true

  # default_scope order: "email"

  belongs_to :owner, class_name: "Organization"

  has_many :actions, class_name: "Version", foreign_key: :whodunnit
  # following architecture
  has_many :flags, as: :owner
  has_many :media_items

  self.per_page = 100

  def self.create_with_omniauth(auth)
    user = User.new
    user.uid = auth['uid']
    user.provider = auth['provider']
    user.name = auth['info']['name']
    user.email = auth['info']['email']

    user.save(validate: false)
    #return
    user
  end


private 

  def create_remember_token
	  self.remember_token = SecureRandom.urlsafe_base64
  end
end
