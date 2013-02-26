class Export < ActiveRecord::Base
  attr_accessible :email, :projects, :status_percent, :file_path
  after_initialize :init

  has_and_belongs_to_many :projects

  validates :email,
    presence: true,
    format: { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ ,
      message: 'Invalid e-mail! Please provide a valid e-mail address'},
      on: :create
 
  def init
    self.status_percent ||= 10 
  end
end
