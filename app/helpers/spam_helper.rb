module SpamHelper

	SPAM_TEXT_FLAGS = [
		"[url=",
		"[URL=",
		"[/url]",
		"[/URL]"
		"</a>", # Humans won't be posting HTML, I promise.
		"</A>",
		"<p>",
		"<P>",

	]

	class ::String
		def is_spam_content?
			SPAM_TEXT_FLAGS.each do |flag|
				return true if self.include?(flag)
			end
			return false
		end
	end




end