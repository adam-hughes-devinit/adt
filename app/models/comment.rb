class Comment < ActiveRecord::Base
  attr_accessible :content, :email, :name, :project_id, :created_at, :published,
                  :geometry, :geocode, :base64_media_item
  has_paper_trail

  default_scope where(published: true)

  after_destroy :touch_project
  after_save :touch_project

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: EMAIL_REGEX}
  validates :content, presence: true

  belongs_to :project
  has_one :geocode, foreign_key => :geocode_id
  has_one :base64_media_item, foreign_key => :base64_media_item_id
  has_one :geometry, foreign_key => :code

  def touch_project
    # touch wasn't forcing reindex!
    project.save!
  end
  
end
