require 'spec_helper'

describe "oda_likes/new" do
  before(:each) do
    assign(:oda_like, stub_model(OdaLike,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new oda_like form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => oda_likes_path, :method => "post" do
      assert_select "input#oda_like_name", :name => "oda_like[name]"
    end
  end
end
