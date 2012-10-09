require "spec_helper"

describe FlowTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/flow_types").should route_to("flow_types#index")
    end

    it "routes to #new" do
      get("/flow_types/new").should route_to("flow_types#new")
    end

    it "routes to #show" do
      get("/flow_types/1").should route_to("flow_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/flow_types/1/edit").should route_to("flow_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/flow_types").should route_to("flow_types#create")
    end

    it "routes to #update" do
      put("/flow_types/1").should route_to("flow_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/flow_types/1").should route_to("flow_types#destroy", :id => "1")
    end

  end
end
