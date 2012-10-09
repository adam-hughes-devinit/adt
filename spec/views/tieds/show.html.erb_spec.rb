require 'spec_helper'

describe "tieds/show" do
  before(:each) do
    @tied = assign(:tied, stub_model(Tied,
      :name => "Name",
      :iati_code => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
  end
end
