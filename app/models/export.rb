class Export < ActiveRecord::Base
  attr_accessible :email, :projects

  has_and_belongs_to_many :projects

  def mail_export
  end
end
