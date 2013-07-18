require 'spec_helper'

describe Comment do
  let(:comment){FactoryGirl.create(:comment)}

  subject {comment}

  describe "Should have a valid factory" do
    it {should be_valid}
  end

end
