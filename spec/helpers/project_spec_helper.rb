module ProjectSpecHelper
	
	def sign_in_aiddata_user
		
		begin
			# On Travis-CI, it asks if I 
			# want to save my password!
			stub_out_confirm {really_sign_in}
		rescue Capybara::NotSupportedByDriverError 
			really_sign_in
		end

	end

	def really_sign_in
		visit staff_login_path
		fill_in "Email", with: aiddata_user.email 
		fill_in "Password", with: aiddata_user.password 
		click_button "Sign in"
	end

	
	def click_save
		find(:css, "input.on-nav-bar").click
	end

	def stub_out_confirm(&block)
		page.evaluate_script('window.original_confirm = window.confirm ')
		page.evaluate_script('window.confirm = function() { return true; }')
		yield
		page.evaluate_script('window.confirm = window.original_confirm ')
	end


end
