require 'spec_helper'

describe "oda_likes/edit" do
  before(:each) do
    @oda_like = assign(:oda_like, stub_model(OdaLike,
      :name => "MyString"
    ))
  end

  it "renders the edit oda_like form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => oda_likes_path(@oda_like), :method => "post" do
      assert_select "input#oda_like_name", :name => "oda_like[name]"
    end
  end
end
