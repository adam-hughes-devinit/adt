require 'spec_helper'

describe "sectors/edit" do
  before(:each) do
    @sector = assign(:sector, stub_model(Sector,
      :name => "MyString",
      :code => 1
    ))
  end

  it "renders the edit sector form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sectors_path(@sector), :method => "post" do
      assert_select "input#sector_name", :name => "sector[name]"
      assert_select "input#sector_code", :name => "sector[code]"
    end
  end
end
