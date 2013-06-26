namespace :flags do
	
	desc "Set some default comment"
	task :fill_in_null_comments => :environment do

		flags_with_empty_comments = Flag.unscoped.where("comment is NULL or comment='' ")
		progress_bar = ProgressBar.new(flags_with_empty_comments)
		DEFAULT_COMMENT = '[No message]'

		flags_with_empty_comments.find_each do |flag|
			flag.update_attributes! comment: DEFAULT_COMMENT
			progress_bar.increment!
		end

	end


end
