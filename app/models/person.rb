class Person < ActiveRecord::Base
  belongs_to :position
  attr_accessible :bio, :email, :first_name, :last_name, :title, :avatar, :avatar_file_name,
                  :position_id, :position, :current_team_member, :page_order

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :url => "people/:style/:filename",
                    :path => ":rails_root/app/assets/images/people/:style/:filename"
  validates_attachment :avatar, :content_type => { :content_type => /^image\/(png|gif|jpeg)/ },
                       :message => 'only (png/gif/jpeg) images'

  before_save :rename_avatar
  validates_uniqueness_of :last_name, :scope => :first_name
  validates_uniqueness_of :page_order, allow_blank: true
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :avatar
  validates_presence_of :position
  validates_presence_of :page_order, if: :validate_position
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true

  def validate_position
    return (self.position_id == 1) # 1 should be "Faculty/Staff"
  end

  def rename_avatar
    #avatar_file_name - important is the first word - avatar - depends on your column in DB table
    extension = File.extname(avatar_file_name).downcase
    self.avatar.instance_write :file_name, (self.first_name.downcase + '_' + self.last_name.downcase + extension)
  end
end
