require 'spec_helper'

describe "verifieds/show" do
  before(:each) do
    @verified = assign(:verified, stub_model(Verified,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
