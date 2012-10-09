require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe OdaLikesController do

  # This should return the minimal set of attributes required to create a valid
  # OdaLike. As you add validations to OdaLike, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OdaLikesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all oda_likes as @oda_likes" do
      oda_like = OdaLike.create! valid_attributes
      get :index, {}, valid_session
      assigns(:oda_likes).should eq([oda_like])
    end
  end

  describe "GET show" do
    it "assigns the requested oda_like as @oda_like" do
      oda_like = OdaLike.create! valid_attributes
      get :show, {:id => oda_like.to_param}, valid_session
      assigns(:oda_like).should eq(oda_like)
    end
  end

  describe "GET new" do
    it "assigns a new oda_like as @oda_like" do
      get :new, {}, valid_session
      assigns(:oda_like).should be_a_new(OdaLike)
    end
  end

  describe "GET edit" do
    it "assigns the requested oda_like as @oda_like" do
      oda_like = OdaLike.create! valid_attributes
      get :edit, {:id => oda_like.to_param}, valid_session
      assigns(:oda_like).should eq(oda_like)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new OdaLike" do
        expect {
          post :create, {:oda_like => valid_attributes}, valid_session
        }.to change(OdaLike, :count).by(1)
      end

      it "assigns a newly created oda_like as @oda_like" do
        post :create, {:oda_like => valid_attributes}, valid_session
        assigns(:oda_like).should be_a(OdaLike)
        assigns(:oda_like).should be_persisted
      end

      it "redirects to the created oda_like" do
        post :create, {:oda_like => valid_attributes}, valid_session
        response.should redirect_to(OdaLike.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved oda_like as @oda_like" do
        # Trigger the behavior that occurs when invalid params are submitted
        OdaLike.any_instance.stub(:save).and_return(false)
        post :create, {:oda_like => {}}, valid_session
        assigns(:oda_like).should be_a_new(OdaLike)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        OdaLike.any_instance.stub(:save).and_return(false)
        post :create, {:oda_like => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested oda_like" do
        oda_like = OdaLike.create! valid_attributes
        # Assuming there are no other oda_likes in the database, this
        # specifies that the OdaLike created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        OdaLike.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => oda_like.to_param, :oda_like => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested oda_like as @oda_like" do
        oda_like = OdaLike.create! valid_attributes
        put :update, {:id => oda_like.to_param, :oda_like => valid_attributes}, valid_session
        assigns(:oda_like).should eq(oda_like)
      end

      it "redirects to the oda_like" do
        oda_like = OdaLike.create! valid_attributes
        put :update, {:id => oda_like.to_param, :oda_like => valid_attributes}, valid_session
        response.should redirect_to(oda_like)
      end
    end

    describe "with invalid params" do
      it "assigns the oda_like as @oda_like" do
        oda_like = OdaLike.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        OdaLike.any_instance.stub(:save).and_return(false)
        put :update, {:id => oda_like.to_param, :oda_like => {}}, valid_session
        assigns(:oda_like).should eq(oda_like)
      end

      it "re-renders the 'edit' template" do
        oda_like = OdaLike.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        OdaLike.any_instance.stub(:save).and_return(false)
        put :update, {:id => oda_like.to_param, :oda_like => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested oda_like" do
      oda_like = OdaLike.create! valid_attributes
      expect {
        delete :destroy, {:id => oda_like.to_param}, valid_session
      }.to change(OdaLike, :count).by(-1)
    end

    it "redirects to the oda_likes list" do
      oda_like = OdaLike.create! valid_attributes
      delete :destroy, {:id => oda_like.to_param}, valid_session
      response.should redirect_to(oda_likes_url)
    end
  end

end
