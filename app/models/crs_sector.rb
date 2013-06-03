class CrsSector < ActiveRecord::Base
  attr_accessible :code, :name
  include ProjectLevelCode


  def full_name
    "#{code} - #{name}"
  end
end
