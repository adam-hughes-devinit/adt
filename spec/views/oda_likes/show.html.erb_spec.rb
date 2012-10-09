require 'spec_helper'

describe "oda_likes/show" do
  before(:each) do
    @oda_like = assign(:oda_like, stub_model(OdaLike,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
