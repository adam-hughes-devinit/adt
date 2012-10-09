require 'spec_helper'

describe Project do
  let(:project) {FactoryGirl.create(:project)}
  let(:status) {FactoryGirl.create(:status)}

  subject {project}

  describe "have a valid Factory" do
  	it {should be_valid}
  end

  describe "requires title" do
  	before {project.title = ''}
  	it {should_not be_valid}
  end

end
