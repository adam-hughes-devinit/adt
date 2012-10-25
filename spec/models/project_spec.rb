require 'spec_helper'

describe Project do
  let(:project) {FactoryGirl.create(:project)}
  let(:status) {FactoryGirl.create(:status)}
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

  describe "requires title" do
  	before {project.title = ''}
  	it {should_not be_valid}
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
