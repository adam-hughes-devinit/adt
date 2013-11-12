class OdaLike < ActiveRecord::Base
  attr_accessible :id, :name, :code, :export, :export_id
  has_paper_trail
  default_scope order: "name"	
  
  def id_for_sql
  	self.id
  end

	has_many :flow_classes, class_name: "FlowClass",
		finder_sql: proc {'SELECT * from flow_classes '  +
								"WHERE (oda_like_2_id = #{id_for_sql}" +
								" or oda_like_1_id = #{id_for_sql} or oda_like_master_id = #{id_for_sql})"
								}
								
  has_many :projects, class_name: "Project",
  	finder_sql: proc {
  							'SELECT * from projects where id in(' +
									'SELECT project_id from flow_classes '  +
									"WHERE (oda_like_2_id = #{id_for_sql}" +
									" or oda_like_1_id = #{id_for_sql} or oda_like_master_id = #{id_for_sql})" +
								")"
								}
end
