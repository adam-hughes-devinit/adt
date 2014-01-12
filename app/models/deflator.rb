class Deflator < ActiveRecord::Base
  belongs_to :country
  attr_accessible :value, :year, :country_id

  validates :value, presence: true
  validates :year, presence: true
  validates :country_id, presence: true

  validates :year, :uniqueness => {:scope => :country_id }

  after_save :calculate_associated_transactions

  # Finds transactions that needed this deflator to calculate usd_defl
  def calculate_associated_transactions
    transactions = Transaction.select("DISTINCT(transactions.project_id)").joins(:project).where(projects: { year: self.year, donor_id: self.country_id } )
    transactions.each do |transaction_record|

       # save project instead of transaction so cache is updated.
      if Transaction.find_by_project_id(transaction_record.project_id).save
        Project.find(transaction_record.project_id).save # Replace with project sweeper.
        LoanDetail.find_by_project_id(transaction_record.project_id).save
      end
    end
  end

end
