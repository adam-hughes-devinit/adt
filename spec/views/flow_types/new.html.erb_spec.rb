require 'spec_helper'

describe "flow_types/new" do
  before(:each) do
    assign(:flow_type, stub_model(FlowType,
      :name => "MyString",
      :iati_code => 1,
      :aiddata_code => 1,
      :oecd_code => 1
    ).as_new_record)
  end

  it "renders new flow_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => flow_types_path, :method => "post" do
      assert_select "input#flow_type_name", :name => "flow_type[name]"
      assert_select "input#flow_type_iati_code", :name => "flow_type[iati_code]"
      assert_select "input#flow_type_aiddata_code", :name => "flow_type[aiddata_code]"
      assert_select "input#flow_type_oecd_code", :name => "flow_type[oecd_code]"
    end
  end
end
