class Comment < ActiveRecord::Base
  attr_accessible :content, :email, :name, :project_id, :created_at, :published
  has_paper_trail

  default_scope where(published: true)

  after_destroy :touch_project
  after_save :touch_project

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: EMAIL_REGEX}
  validates :content, presence: true
  validates :name, presence: true

  belongs_to :project


  def touch_project
    # touch wasn't forcing reindex!
    project.save!
  end
  
end
