require "spec_helper"

describe OdaLikesController do
  describe "routing" do

    it "routes to #index" do
      get("/oda_likes").should route_to("oda_likes#index")
    end

    it "routes to #new" do
      get("/oda_likes/new").should route_to("oda_likes#new")
    end

    it "routes to #show" do
      get("/oda_likes/1").should route_to("oda_likes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/oda_likes/1/edit").should route_to("oda_likes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/oda_likes").should route_to("oda_likes#create")
    end

    it "routes to #update" do
      put("/oda_likes/1").should route_to("oda_likes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/oda_likes/1").should route_to("oda_likes#destroy", :id => "1")
    end

  end
end
