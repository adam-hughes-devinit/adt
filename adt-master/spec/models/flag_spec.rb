require 'spec_helper'

describe Flag do
 # let(:flag_type){FactoryGirl.define(:flag_type)}
 let(:flag){FactoryGirl.create(:flag)}
 
 subject { flag }
 
	describe "have valid factories" do
	 it {should be_valid}
	end

end
