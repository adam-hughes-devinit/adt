class ExchangeRate < ActiveRecord::Base
  belongs_to :from_currency, :class_name => "Currency"
  belongs_to :to_currency, :class_name => "Currency"
  attr_accessible :rate, :year, :from_currency_id, :to_currency_id

  validates :rate, presence: true
  validates :year, presence: true
  validates :from_currency_id, presence: true
  validates :to_currency_id, presence: true

  validates :year, :uniqueness => {:scope => [:from_currency_id, :to_currency_id]}

  after_save :calculate_associated_transactions

  def calculate_associated_transactions
    transactions = Transaction.select("DISTINCT(transactions.project_id)").joins(:project).where(projects: { year: self.year }, currency_id: self.from_currency_id )
    transactions.each do |transaction_record|

       # Save transaction and loan detail so they are recalculated
      if Transaction.find_by_project_id(transaction_record.project_id).save
        LoanDetail.find_by_project_id(transaction_record.project_id).save

         # Delete cache for the project, so cache is updated.
        project = Project.find(transaction_record.project_id)
        delete_project_cache(project)

      end
    end
  end


end
