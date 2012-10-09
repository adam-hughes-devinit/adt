require 'spec_helper'

describe "verifieds/edit" do
  before(:each) do
    @verified = assign(:verified, stub_model(Verified,
      :name => "MyString"
    ))
  end

  it "renders the edit verified form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => verifieds_path(@verified), :method => "post" do
      assert_select "input#verified_name", :name => "verified[name]"
    end
  end
end
