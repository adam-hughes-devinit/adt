module ProjectSpecHelper
	
	def sign_in_aiddata_user
		visit staff_login_path
		fill_in "Email", with: aiddata_user.email 
		fill_in "Password", with: aiddata_user.password 
		click_button "Sign in"
	end
	
	def click_save
		find(:css, "input.on-nav-bar").click
	end

end
