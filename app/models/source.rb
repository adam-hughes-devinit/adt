class Source < ActiveRecord::Base
  attr_accessible :date, :document_type_id, :source_type_id, :url, :project_id, :source_type, :document_type
  has_paper_trail

  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags

  belongs_to :document_type
  belongs_to :source_type 
  belongs_to :project 
end
