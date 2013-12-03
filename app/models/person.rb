class Person < ActiveRecord::Base
  belongs_to :position
  attr_accessible :bio, :email, :first_name, :last_name, :title, :avatar, :avatar_file_name,
                  :position_id, :current_team_member

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :url => "people/:filename",
                    :path => ":rails_root/app/assets/images/people/:filename"
  validates_attachment :avatar, :content_type => { :content_type => /^image\/(png|gif|jpeg)/ },
                       :message => 'only (png/gif/jpeg) images'

  before_save :rename_avatar

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :avatar
  validates_presence_of :email
  validates_presence_of :position
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def rename_avatar
    #avatar_file_name - important is the first word - avatar - depends on your column in DB table
    extension = File.extname(avatar_file_name).downcase
    self.avatar.instance_write :file_name, (self.first_name.downcase + '_' + self.last_name.downcase + extension)
  end
end
