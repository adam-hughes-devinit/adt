class Comment < ActiveRecord::Base
  attr_accessible :content, :email, :name, :project_id
  has_paper_trail
  
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: EMAIL_REGEX}
  validates :content, presence: true

  belongs_to :project

end
