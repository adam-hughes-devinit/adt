class User < ActiveRecord::Base
  
  attr_accessible :email, :name, 
  :password, :password_confirmation,
  :owner, :owner_id, :admin
  
  has_secure_password
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, format: {with: EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: 6}
  validates :password_confirmation, presence: true

  default_scope order: "email"

  belongs_to :owner, class_name: "Organization"

  has_many :actions, class_name: "Version", foreign_key: :whodunnit
  # following architecture
  has_many :relationships, foreign_key: :follower_id
  has_many :followed_users, through: :relationships,
            source: :followed, 
            conditions: lambda { "followed_type = 'User'" }


  def follow!(user_or_project)
      relationships.create!(followed_id: user_or_project.id, followed_type: user_or_project.class.name)
  end
private 

  def create_remember_token
	 self.remember_token = SecureRandom.urlsafe_base64
	end

end
