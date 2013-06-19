class AggregateFlow

	include AggregateValidators	

	def initialize(get: ["donor"], where: {}, duplication_handler: DUPLICATION_HANDLERS.first)
		raise TypeError, "`get` must be an Array" unless get.is_a? Array
		raise TypeError, "`where` must be a hash" unless where.is_a? Hash 

		@validated_gets = []
		VALID_FIELDS.each do |field|
			if get.include?(field[:external])
				@validated_gets << field
			end
		end

		raise NoMethodError, "No fields requested!" unless @validated_gets.any?
		@sorter = @validated_gets.last[:sorter]

		@validated_filters = ["active = 't'"]
		WHERE_FILTERS.each do |filter|
			if values = where[filter[:sym]]
				(raise TypeError, "where values must be Array!" unless values.is_a? Array)
				valid_values = (values & filter[:options])
				@validated_filters.push "#{filter[:internal_filter]} in ('#{valid_values.join("','")}')"
			end
		end

		@duplication_handler = duplication_handler

	end

	def execute!
		sql = self.to_sql
		ActiveRecord::Base.connection.execute(sql)
	end

	def to_json
		data = execute!
		data.as_json(only: column_names)
	end

	def to_csv
		data = execute!
		CSV.generate do |csv|
			csv << column_names
			data.each do |datum|
				csv << datum.values_at(*column_names)
			end
		end
	end

	def column_names
		@validated_gets.map{|f| f[:external]} + ["usd_2009", "usd_current", "count"] 
	end

	def to_sql
		# My apologies. It's better than it was -- 
		# it used to just be running willy-nilly in 
		# Aggregates controller...
		# To do: look at ActiveRecord Calculations
		sql = %{
select 
	#{@duplication_handler[:amounts]}, 
	count(*) as count,
	#{@validated_gets.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}
from 
	(select projects.*, 
	#{eval(@duplication_handler[:select])}
	from projects 
	#{@duplication_handler[:join]}
	#{@duplication_handler[:group]}
	) as p 
LEFT OUTER JOIN 
	(select 
		id, project_id, oda_like_1_id, oda_like_2_id, oda_like_master_id, 
		(case 
			when oda_like_master_id is not null then oda_like_master_id 
			when oda_like_2_id is not null then oda_like_2_id 
			else oda_like_1_id 
		end) oda_like_best_id 
	from flow_classes) as modified_flow_classes 
	on p.id = modified_flow_classes.project_id 
LEFT OUTER JOIN oda_likes on modified_flow_classes.oda_like_best_id = oda_likes.id	
LEFT OUTER JOIN crs_sectors on p.crs_sector_id = crs_sectors.id
LEFT OUTER JOIN flow_types on p.flow_type_id = flow_types.id
LEFT OUTER JOIN verifieds on p.verified_id = verifieds.id
LEFT OUTER JOIN statuses on p.status_id = statuses.id
LEFT OUTER JOIN intents on p.intent_id = intents.id		 				
INNER JOIN countries donors on p.donor_id = donors.id 
LEFT OUTER JOIN 
	(select 
		sum(usd_current) as sum_usd_current, 
		sum(usd_defl) as sum_usd_defl, 
		project_id 
	from transactions 
	group by project_id) as t 
	on p.id = t.project_id
where 
	#{@validated_filters.join(' and ').gsub(/(\w)'(\w)/, '\1\'\'\2')}
group by 
	#{@validated_gets.map{|f| Rails.env.test? ? f[:group] : f[:internal]  }.join(', ')} 
order by 
	#{@sorter}
	}

		sql
	end

end
