require 'spec_helper'

describe Contact do
	let(:contact){FactoryGirl.create(:contact)}
	
	subject {contact}
	

	describe "Should have a valid factory" do
		it {should be_valid}
	end

end
