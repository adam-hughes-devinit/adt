require 'spec_helper'

describe "verifieds/new" do
  before(:each) do
    assign(:verified, stub_model(Verified,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new verified form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => verifieds_path, :method => "post" do
      assert_select "input#verified_name", :name => "verified[name]"
    end
  end
end
