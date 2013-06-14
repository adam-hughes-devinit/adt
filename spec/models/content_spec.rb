require 'spec_helper'

describe Content do
	let(:content){FactoryGirl.create :content }


	subject {content}
	
	
	describe "should have a valid factory" do
		it {should be_valid}
	end

	it {should respond_to(:to_english)}


end