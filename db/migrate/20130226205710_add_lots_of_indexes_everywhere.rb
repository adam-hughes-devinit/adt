class AddLotsOfIndexesEverywhere < ActiveRecord::Migration
  def change
  	add_index :comments, :project_id
	add_index :contacts, :organization_id
	add_index :countries, :name
	add_index :countries, :iso3
	add_index :currencies, :name
	add_index :currencies, :iso3
	add_index :document_types, :name
	add_index :flags, :flaggable_id
	add_index :flags, :flaggable_type
	add_index :flags, [:flaggable_id, :flaggable_type]
	add_index :flags, :flag_type_id
	add_index :flow_classes, :project_id
	add_index :flow_classes, :oda_like_1_id
	add_index :flow_classes, :oda_like_2_id
	add_index :flow_classes, :oda_like_master_id
	add_index :flow_types, :name
	add_index :geopoliticals, :recipient_id
	add_index :intents, :name
	add_index :loan_details, :project_id
	add_index :loan_details, :loan_type_id
	add_index :oda_likes, :name
	add_index :organization_types, :name
	add_index :organizations, :organization_type_id
	add_index :origins, :name
	add_index :participating_organizations, :organization_id
	add_index :projects, :title
	add_index :projects, :year
	add_index :projects, :flow_type_id
	add_index :projects, :sector_id
	add_index :projects, :status_id
	add_index :projects, :verified_id
	add_index :projects, :donor_id
	add_index :projects, :active
	add_index :projects, :intent_id
	add_index :projects, :crs_sector
	add_index :roles, :name
	add_index :scope_channels, :scope_id
	add_index :scope_filter_values, :scope_filter_id
	add_index :scope_filters, :scope_channel_id
	add_index :scopes, :name
	add_index :scopes, :symbol
	add_index :sectors, :name
	add_index :source_types, :name
	add_index :sources, :source_type_id
	add_index :sources, :document_type_id
	add_index :statuses, :name
	add_index :transactions, :currency_id
	add_index :users, :email
  end


end
