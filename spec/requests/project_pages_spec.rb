require 'spec_helper'

describe "Project pages" do
  let(:project) {FactoryGirl.create(:project)}

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
  end


end
