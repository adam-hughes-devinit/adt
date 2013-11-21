class Deflator < ActiveRecord::Base
  belongs_to :country
  attr_accessible :value, :year, :country_id

  validates :value, presence: true
  validates :year, presence: true
  validates :country_id, presence: true

  validates :year, :uniqueness => {:scope => :country_id }

  #after_save :calculate_associated_transactions
  after_save :recalculate_all_transactions

   # Finds transactions that needed this deflator to calculate usd_defl
  def calculate_associated_transactions
    transactions = Transaction.joins(:project).where(projects: { year: self.year, donor_id: self.country_id } )
    transactions.each do |transaction_record|
      if Transaction.find(transaction_record.id).save
        LoanDetail.find_by_project_id(transaction_record.project_id).save
      end
    end
  end

   # Temporary for large update
  def recalculate_all_transactions
    Transaction.all.each do |transaction|
      if transaction.save
        LoanDetail.find_by_project_id(transaction.project_id).save
      end
    end
  end

end
