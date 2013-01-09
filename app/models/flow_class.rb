class FlowClass < ActiveRecord::Base
  attr_accessible :project_id, :project, 
  :oda_like_1_id, :oda_like_1, 
  :oda_like_2_id, :oda_like_2, 
  :oda_like_master, :oda_like_master_id

  before_save :auto_arbitrate  

  belongs_to :project  
  belongs_to :oda_like_1, class_name: 'OdaLike'
  belongs_to :oda_like_2, class_name: 'OdaLike'
  belongs_to :oda_like_master, class_name: 'OdaLike'
  
  def show_round(round)
		if oda_like =	self.send("oda_like_#{round}")
			"<a href='/oda_likes/#{oda_like.id}/'>#{oda_like.name}</a>".html_safe
		else 
			""
		end
	end
	
	def auto_arbitrate
		if !self.oda_like_master
			if self.oda_like_1 && self.oda_like_1_id == self.oda_like_2_id
				self.oda_like_master_id = self.oda_like_1_id
			end
		end
	end
	
end
