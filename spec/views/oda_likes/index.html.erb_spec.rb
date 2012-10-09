require 'spec_helper'

describe "oda_likes/index" do
  before(:each) do
    assign(:oda_likes, [
      stub_model(OdaLike,
        :name => "Name"
      ),
      stub_model(OdaLike,
        :name => "Name"
      )
    ])
  end

  it "renders a list of oda_likes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
