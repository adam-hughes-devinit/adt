class ProjectsController < ApplicationController  
before_filter :set_owner, only: [:create, :new]
before_filter :correct_owner?, only: [:edit]
include SearchHelper


  def index

    respond_to do |format|
      format.html do
   			custom_search
        render html: @projects
      end
      format.json do
				custom_search({default_to_official_finance: false})
        render json: @projects
      end
      format.csv do
   			custom_search
        params[:max] = Project.all.count
        @ids_for_export = @projects.map { |p| p.id }
        
        if @ids_for_export.length == Project.all.count
        	@csv_data = Cache.find(0).text # this is a chill hack -- id=0 holds all the text.
        	full_or_partial="full"
        else	
        	@csv_data = Cache.where("id in(?)", @ids_for_export ).map{|c| c.text } .join("
")				
					full_or_partial="partial"
				end
				@csv_header = Project.csv_header

        send_data((@csv_header + "\n" + @csv_data), filename: "AidData_China_#{full_or_partial}_#{Time.now.strftime("%y-%m-%d-%H:%M:%S.%L")}.csv")
        
        #    This was the old way of doing it -- creating the file in memory from projects dynamically
        #@export_projects = Project.includes(:transactions, :geopoliticals, :contacts, :sources, :participating_organizations)
        #.where("id in(?)", 
        #  @projects.map{ |p| p.id})
        #send_data @export_projects.to_csv
      end
    end
  end


  def show
    @project = Project.find(params[:id])
    @comment = Comment.new
    @history = @project.history
    @flags = @project.all_flags
    @flag = Flag.new
    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    @loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/new
  # GET /Projects/new.json
  def new
    @project = Project.new(owner: @new_owner)
    @project.transactions.build
    @project.geopoliticals.build
    @project.participating_organizations.build
    @project.contacts.build
    @project.sources.build
    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    @loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    @loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)

  end

  # POST /Projects
  # POST /Projects.json
  def create
    @project = Project.new(params[:project])
    strip_tags_from_description

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end


  end

  # PUT /Projects/1
  # PUT /Projects/1.json
  def update
    @project = Project.find(params[:id])


    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end

    undo_link = view_context.link_to( 
    "Undo", revert_version_path(@project.versions.scoped.last
    ),
    #"Undo", "/versions/#{@object.versions.last.id}/revert",
    method: :post)
    flash[:success] = "Project updated. #{undo_link}"
  end

  # DELETE /Projects/1
  # DELETE /Projects/1.json
  def destroy
  	
  
    @project = Project.find(params[:id])
    @cache = Cache.find(params[:id])
    
    # The big problem here was that in @project.destroy, 
    # all the accessory objects were destroyed _first_,
    # so when @project was destroyed (and accessories were saved),
    # the accessories were gone already and accessories was an empty array.
    #
    # To get around this, I'm saving the accessories, deleting everything,
    # then adding the accessories by hand. 
    @accessories = @project.accessories
    
    @project.destroy
    @cache.destroy
    
    @last_version = @project.versions.scoped.last
    @last_version.accessories = @accessories
    @last_version.save!

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
    
    undo_link = view_context.link_to( 
    "Undo", revert_version_path(@project.versions.scoped.last
    ),
    method: :post)
    flash[:notice] = "Project deleted! #{undo_link}"
  end

  private

    def correct_owner? 
      project_owner = Project.find(params[:id]).owner 
      unless signed_in? && current_user.owner.present? && (current_user.owner == project_owner)
        flash[:notice] = "Only #{project_owner.name} can edit this record."
        redirect_to Project.find(params[:id])
      end

    end
    def set_owner
      @new_owner = current_user.owner if signed_in?
    end

    def strip_tags_from_description
      @project.description = view_context.strip_tags(@project.description)
      
      # hack when data uploading
      # if @project.title.blank?
      #   @project.title = "Unset"
      # end

    end
  
  


end
