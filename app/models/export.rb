class Export < ActiveRecord::Base
  attr_accessible :email, :projects, :status_percent
  after_initialize :init

  has_and_belongs_to_many :projects
 
  def init
    self.status_percent ||= 10 
  end
end
