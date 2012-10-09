require 'spec_helper'

describe "sectors/index" do
  before(:each) do
    assign(:sectors, [
      stub_model(Sector,
        :name => "Name",
        :code => 1
      ),
      stub_model(Sector,
        :name => "Name",
        :code => 1
      )
    ])
  end

  it "renders a list of sectors" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
