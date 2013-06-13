require 'spec_helper'

describe Project do
  let(:project) {FactoryGirl.create(:project)}
  let(:transaction) {FactoryGirl.build(:transaction)}
  let(:geopolitical) {FactoryGirl.build(:geopolitical)}
  let(:participating_organization) {FactoryGirl.build(:participating_organization)}
  let(:contact) {FactoryGirl.build(:contact)}
  let(:source) {FactoryGirl.build(:source)}
  let(:comment) {FactoryGirl.build(:comment)}
  subject {project}

  describe "have a valid Factory" do
  	it {should be_valid}
  end

  it { should respond_to :transactions}
  it { should respond_to :geopoliticals}
  it { should respond_to :participating_organizations}
  it { should respond_to :contacts}
  it { should respond_to :sources}

  it {should respond_to :comments}

  describe "should accept a transaction" do
    before {project.transactions << transaction }
    it {should be_valid}
  end

  describe "Should accept a geopolitical" do
    before { project.geopoliticals << geopolitical}
    it {should be_valid}
  end

  describe "Should accept a participating_organization" do
    before { project.participating_organizations << participating_organization}
    it {should be_valid}
  end

  describe "Should accept a contact" do
    before { project.contacts << contact}
    it {should be_valid}
  end

  describe "Should accept a source" do
    before { project.sources << source}
    it {should be_valid}
  end

  describe "Should accept a comment" do
    before { project.comments << comment}
    it {should be_valid}
  end

end


=begin
describe "official project" do
  subject {FactoryGirl.create(:project, :offic)}

  describe "Should recognize offical scope" do
    its(:scope) { should include :official_finance }
    its(:oda_like) {should eq "1"}
    its(:oda_like_name) {should eq "OOF-like"}
  end

end

describe "unofficial project" do

  subject {FactoryGirl.create(:project, :unoffic)}

  describe "Should recognize unofficial scope" do
    its(:scope) { should include :unofficial_finance }
  end
end

describe "military project" do

  subject {FactoryGirl.create(:project, :military)}

  describe "Should recognize military scope" do
    its(:scope) { should include :military }
  end
end

describe "cancelled project" do

  subject {FactoryGirl.create(:project, :cancelled)}

  describe "Should recognize cancelled scope" do
    its(:scope) { should include :cancelled }
  end
end

describe "suspicious or inactive project" do

  subject {FactoryGirl.create(:project, :sus)}
  @inact = FactoryGirl.create(:project, :inact)

  describe "Should recognize suspicious_or_inactive scope" do
    its(:scope) { should include :suspicious_or_inactive}
    #@inact.scope { should include :suspicious_or_inactive}
  end

end
=end
