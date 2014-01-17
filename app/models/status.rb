class Status < ActiveRecord::Base
  attr_accessible :iati_code, :name, :code

  validates_presence_of :iati_code, :name, :code

  include ProjectLevelCode

end
