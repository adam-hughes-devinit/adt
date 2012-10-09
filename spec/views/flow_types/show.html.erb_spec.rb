require 'spec_helper'

describe "flow_types/show" do
  before(:each) do
    @flow_type = assign(:flow_type, stub_model(FlowType,
      :name => "Name",
      :iati_code => 1,
      :aiddata_code => 2,
      :oecd_code => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
