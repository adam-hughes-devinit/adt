class CrsSector < ActiveRecord::Base
  attr_accessible :code, :name

  has_paper_trail

  has_many :projects

  def full_name
    "#{code} - #{name}"
  end
end
