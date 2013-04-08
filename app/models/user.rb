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

  default_scope order: "email"

  belongs_to :owner, class_name: "Organization"

  has_many :actions, class_name: "Version", foreign_key: :whodunnit
  # following architecture
  has_many :relationships, foreign_key: "follower_id"
  has_many :flags, as: :owner

  def followed_user_ids
    relationships.map do |i| 
      if i.followed_type == "User"
        User.find_by_id(i.followed_id).id
      end
    end
  end

  def followed_project_ids
    relationships.map do |i| 
      if i.followed_type == "Project"
        Project.find_by_id(i.followed_id).id
      end
    end
  end

  # def followed_all 
  #   self.followed_users + self.followed_projects
  # end

  def feed 
    Version.where("whodunnit=? or whodunnit in (?) or (item_type='Project' and item_id in (?))", id, followed_user_ids, followed_project_ids)
  end






  def follow!(user_or_project)
      relationships.create!(follower_id: self.id, followed_id: user_or_project.id, followed_type: user_or_project.class.name)
  end
  def following?(user_or_project)
    Relationship.find_by_followed_id_and_followed_type(user_or_project.id, user_or_project.class.name)
  end

  def unfollow!(user_or_project)
      Relationship.find_by_followed_id_and_followed_type(user_or_project.id, user_or_project.class.name).destroy
  end

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
