class Deflator < ActiveRecord::Base
  belongs_to :country
  attr_accessible :value, :year, :country_id

  validates :value, presence: true
  validates :year, presence: true
  validates :country_id, presence: true

  validates :year, :uniqueness => {:scope => :country_id }

  after_save :calculate_associated_transactions
  #after_save :recalculate_all_projects

  # Finds transactions that needed this deflator to calculate usd_defl
  def calculate_associated_transactions_break
    transactions = Transaction.joins(:project).where(projects: { year: self.year, donor_id: self.country_id } )
    transactions.each do |transaction_record|
      if Transaction.find(transaction_record.id).save
        LoanDetail.find_by_project_id(transaction_record.project_id).save
        Project.find(transaction_record.project_id).save
      end
    end
  end

   # This should replace the method above, but for some reason it is not working.
  def calculate_associated_transactions
    transactions = Transaction.select("DISTINCT(transactions.project_id)").joins(:project).where(projects: { year: self.year, donor_id: self.country_id } )
    transactions.each do |transaction_record|

       # save project instead of transaction so cache is updated.
      if Transaction.find_by_project_id(transaction_record.project_id).save
        Project.find(transaction_record.project_id).save
        LoanDetail.find_by_project_id(transaction_record.project_id).save
      end
    end
  end
  
   # This should recalculate all projects. Used for testing and does not appear to be working like the mehtod above.
  def recalculate_all_projects
    Project.all.each do |project|
      if project.save
        LoanDetail.find_by_project_id(project.id).save
      end
    end
  end

end
