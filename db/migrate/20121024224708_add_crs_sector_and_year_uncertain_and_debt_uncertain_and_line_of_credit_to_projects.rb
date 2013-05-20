class AddCrsSectorAndYearUncertainAndDebtUncertainAndLineOfCreditToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :crs_sector, :integer
    add_column :projects, :debt_uncertain, :boolean, default: false
    add_column :projects, :year_uncertain, :boolean, default: false
    add_column :projects, :line_of_credit, :boolean, default: false
  end
end
