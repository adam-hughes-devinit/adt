require 'spec_helper'

describe "Project pages" do
  let(:user) { FactoryGirl.create(:user) }
  let(:project) {FactoryGirl.create(:project)}
  let(:country) {FactoryGirl.create(:country)}
  let(:currency) {FactoryGirl.create(:currency)}
  let(:organization) {FactoryGirl.create(:organization)}
  let(:contact) {FactoryGirl.create(:contact)}
  let(:comment) {FactoryGirl.build(:comment)}
  let(:flag_type) {FactoryGirl.create(:flag_type)}
  let(:transaction){FactoryGirl.create(:transaction)}
  let(:flag) {FactoryGirl.create(:flag)}

   
  subject {page}
  
  
  describe " #edit should be impervious to un-signed-in users" do
    before do 
        visit edit_project_path(project)
      end

      it {should_not have_selector("button", text: "Save")}
  end
 
  describe "Should be editable by signed-in users" do
    before do
          visit signin_path
          fill_in "Email", with: user.email 
          fill_in "Password", with: user.password 
          click_button "Sign in"
          visit edit_project_path(project)
    end

    it { should_not have_selector("button", text: "Save")}
  end


  describe "view a project" do
    before do
	    flag_type.save
	    transaction.flags << flag
      project.transactions << transaction
  		project.save!
    	visit project_path(project)
    end
    # test page title
    it {should have_selector("title", text: project.title)}
    # test main div
  	it {should have_content(project.description)}
    # test dates div
    it {should have_content(project.start_actual.strftime("%d %B %Y"))}
    # test details div
    it {should have_content(project.sector.name)}
    it {should have_content(project.flow_type.name)}
    it {should have_content(project.status.name)}
    it {should have_content(project.donor.name)}

		describe "Flag link" do
			it {should have_content(flag_type.name)}
    
		  describe "see a Flag popover -- Can't get it to work! " do 
		  	before do   		
		  		p FlagType.all.map(&:name)
		  		# save_and_open_page
		  		find(".flag-link-#{flag_type.name}").click
		  	end
		  	# Screw it!!
		  	it {should have_content("#{flag_type.name} this:")}
		  end
		end

		describe "Flag text" do
			it {should have_content flag.comment}
		end
		
    it {should have_content("Leave a comment")}
    describe "leave a comment" do
      before do
        fill_in "Name", with: comment.name
        fill_in "Email", with: comment.email
        fill_in "Message", with: comment.content
        click_button "Submit"
      end

      it {should have_content(comment.name)}
      it {should have_content(comment.content)}
      it {should_not have_content(comment.email)}
    end
    


  end

  describe "create a project " do
    before do
          visit signin_path
          fill_in "Email", with: user.email 
          fill_in "Password", with: user.password 
          click_button "Sign in"
          visit new_project_path
    end

    it {should have_content("New Project")}
    
    # There isn't really invalid information... 
    #
    # it "should reject with invalid information" do
    #  expect {click_button "Save"}.not_to change(Project, :count)
    # end

    describe "with valid information" do
      before do
        fill_in "Title", with: "New project title"
        select country.name, from: "Donor country"
        fill_in "Description", with: "New project description"
        fill_in "Year", with: "2001"
        fill_in "Capacity", with: "5 doctors"
        # fill_in "Start actual", with: 10.days.ago
        select "Suspicious", from: "Verified"
        # select "OOF-Like", from: "Oda like"
        fill_in "Value", with: 5000
        select Currency.first.name, from: "Currency"
        select country.name, from: "Recipient country"
        fill_in "Detail", with: "Cupcake City"
        select Organization.first.name, from: "Organization"
        fill_in "Contact name", with: "Hu Jintao"
        fill_in "Contact position", with: "President"
      end

      it {should have_content(user.owner.name)}

      describe "the project data is saved" do
        before {click_button "Save"}


        it {should have_content(project.donor.name)}
        it {should have_content("New project description")}
        it {should have_content("Suspicious")}
        it {should have_content(Organization.first.name)}
        it {should have_content("Role: Unset")}

        describe "should display the Currency ISO " do
          it {should have_content(Currency.first.iso3)}
        end
        
        describe "should show the Subnational " do
          it {should have_content("Cupcake City")}
        end

        describe "should show the contact info " do
          it {should have_content("Hu Jintao")}
          it {should have_content("President")}
        end

        # test that the user who made it now owns it
        it {should have_content(user.owner.name)}

		    describe "editing the project" do
		      before do
		        click_link "Edit this project"
		      end

		      describe "changing description and transaction"  do
		        before do
    	        fill_in "Description", with: "new description"
			        # click_link "Remove Transaction" 
			        #      I wish I could get that to work!
		        end
		        
		        it {should have_content "Remove Transaction"}
		        describe "then save the project" do
		        	before do
			        	click_button "Save"
			        end
			        
			        it "should have some version control" do
			        	should have_link("Undo")
			        end
			        
			        describe "visiting the new project" do
								it {should have_content "new description"}
						  	it {should have_content(Currency.first.iso3)}
						  end

			      end
			      		        
		       end
		     end			
      end
    end  

    




  end
end
