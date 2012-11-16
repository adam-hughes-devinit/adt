require 'spec_helper'

describe Cache do
  let(:cache){FactoryGirl.create(:cache)}
  
  subject {cache}
	

	describe "Should have a valid factory" do
		it {should be_valid}
	end

end
