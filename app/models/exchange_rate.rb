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

   # Finds transactions that needed this exchange_rate to calculate usd_defl
  def calculate_associated_transactions
    transactions = Transaction.joins(:project).where(projects: { year: self.year }, currency_id: self.from_currency_id )
    transactions.each do |transaction_record|
      if Transaction.find(transaction_record.id).save
        LoanDetail.find_by_project_id(transaction_record.project_id).save
      end
    end
  end


end
