require "spec_helper"

describe VerifiedsController do
  describe "routing" do

    it "routes to #index" do
      get("/verifieds").should route_to("verifieds#index")
    end

    it "routes to #new" do
      get("/verifieds/new").should route_to("verifieds#new")
    end

    it "routes to #show" do
      get("/verifieds/1").should route_to("verifieds#show", :id => "1")
    end

    it "routes to #edit" do
      get("/verifieds/1/edit").should route_to("verifieds#edit", :id => "1")
    end

    it "routes to #create" do
      post("/verifieds").should route_to("verifieds#create")
    end

    it "routes to #update" do
      put("/verifieds/1").should route_to("verifieds#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/verifieds/1").should route_to("verifieds#destroy", :id => "1")
    end

  end
end
