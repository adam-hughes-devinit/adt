require 'spec_helper'

describe "tieds/edit" do
  before(:each) do
    @tied = assign(:tied, stub_model(Tied,
      :name => "MyString",
      :iati_code => 1
    ))
  end

  it "renders the edit tied form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tieds_path(@tied), :method => "post" do
      assert_select "input#tied_name", :name => "tied[name]"
      assert_select "input#tied_iati_code", :name => "tied[iati_code]"
    end
  end
end
