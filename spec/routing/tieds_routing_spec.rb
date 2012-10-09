require "spec_helper"

describe TiedsController do
  describe "routing" do

    it "routes to #index" do
      get("/tieds").should route_to("tieds#index")
    end

    it "routes to #new" do
      get("/tieds/new").should route_to("tieds#new")
    end

    it "routes to #show" do
      get("/tieds/1").should route_to("tieds#show", :id => "1")
    end

    it "routes to #edit" do
      get("/tieds/1/edit").should route_to("tieds#edit", :id => "1")
    end

    it "routes to #create" do
      post("/tieds").should route_to("tieds#create")
    end

    it "routes to #update" do
      put("/tieds/1").should route_to("tieds#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/tieds/1").should route_to("tieds#destroy", :id => "1")
    end

  end
end
