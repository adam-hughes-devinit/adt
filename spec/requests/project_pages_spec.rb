require 'spec_helper'

describe "Project pages" do
  let(:user) { FactoryGirl.create(:user) }
  let(:project) {FactoryGirl.create(:project)}
  before do
        visit signin_path
        fill_in "Email", with: user.email 
        fill_in "Password", with: user.password 
        click_button "Sign in"
  end


  subject {page}

  describe "view a project" do
    before {visit project_path(project)}
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

  end

  describe "create a project " do
    before {visit new_project_path}

    it {should have_content("Create a new project")}
    
    it "should reject with invalid information" do
      expect {click_button "Save"}.not_to change(Project, :count)
    end

    describe "with valid information" do
      before do 
        fill_in "Title", with: "New project title"
        fill_in "Donor country", with: "China"
        fill_in "Description", with: "New project description"
        fill_in "Year", with: "2001"
        fill_in "Capacity", with: "5 doctors"
        # fill_in "Start actual", with: 10.days.ago
        fill_in "Verified", with: "Suspicious"
        fill_in "Oda like", with: OdaLike.first
      end

      it {should have_content(user.owner.name)}

      it "it should save the project" do
        expect {click_button "Save"}.to change(Project.count).by(1)
      end

    end

    describe "the project data is saved" do
      before {visit project_path(project)}

      it {should have_content(project.donor.name)}
      it {should have_content(project.description)}
      it {should have_content(project.verified.name)}

      # test that the user who made it now owns it
      it {should have_content(user.owner.name)}
    end    

  end

end
