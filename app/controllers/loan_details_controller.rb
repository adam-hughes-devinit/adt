class LoanDetailsController < ApplicationController
  # GET /loan_details
  # GET /loan_details.json
  def index
    @loan_details = LoanDetail.all


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @loan_details }
    end
  end

  # GET /loan_details/1
  # GET /loan_details/1.json
  def show
    @loan_detail = LoanDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @loan_detail }
    end
  end

  # GET /loan_details/new
  # GET /loan_details/new.json
  def new
    @loan_detail = LoanDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @loan_detail }
    end
  end

  # GET /loan_details/1/edit
  def edit
    @loan_detail = LoanDetail.find(params[:id])



  end

  # POST /loan_details
  # POST /loan_details.json
  def create
    @project = Project.find(params[:project_id])
    @loan_detail = LoanDetail.create(params[:loan_detail])
    @loan_detail.project_id = @project.id

    respond_to do |format|
      if @loan_detail.save
        format.html { redirect_to project_path(@project.id), notice: 'Loan detail was successfully created.' }
        format.json { render json: @loan_detail, status: :created, location: @loan_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @loan_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /loan_details/1
  # PUT /loan_details/1.json
  def update
    @loan_detail = LoanDetail.find(params[:id])
    @project = Project.find(params[:project_id])
    respond_to do |format|
      if @loan_detail.update_attributes(params[:loan_detail])
        format.html { redirect_to project_path(@project.id), notice: 'Loan detail was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @loan_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loan_details/1
  # DELETE /loan_details/1.json
  def destroy
    @loan_detail = LoanDetail.find(params[:id])
    @loan_detail.destroy

    respond_to do |format|
      format.html { redirect_to loan_details_url }
      format.json { head :no_content }
    end
  end
end
