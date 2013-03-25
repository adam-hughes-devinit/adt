class ProjectsController < ApplicationController  
before_filter :set_owner, only: [:create, :new]
before_filter :correct_owner?, only: [:edit]
include SearchHelper

caches_action :show, :cache_path => Proc.new { |c| "projects/#{c.params[:id]}/#{current_user_is_aiddata}" }
caches_action :index, :cache_path => Proc.new { |c| "projects/index/#{current_user_is_aiddata}?#{c.params.inspect}" }

  def index
   
    respond_to do |format|
      format.html do
        @full_results = custom_search(paginate: false)
   			@projects = custom_search
        @export = Export.new(params[:export])
        render html: @projects
      end
      format.json do
				@projects = custom_search({default_to_official_finance: false})
        render json: @projects
      end
      format.csv do
        if params[:page]
          @paginate = true
        else
          @paginate = false
        end
   			@projects = custom_search(paginate: @paginate, default_to_official_finance: false)
        
        @ids_for_export = @projects.map { |p| p.id }
        @csv_data = Cache.where("id in(?)", @ids_for_export ).map{|c| c.text } .join("
")				
				
        @csv_header = Project.csv_header


        send_data((@csv_header + "\n" + @csv_data), filename: "AidData_China_custom_#{Time.now.strftime("%y-%m-%d-%H:%M:%S.%L")}.csv")

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
    @flow_class = @project.flow_class = FlowClass.new
    @loan_detail = @project.loan_detail = LoanDetail.new

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

    expire_this_cache


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

    # defined below
    expire_this_cache

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
    # defined below
    expire_this_cache

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
  
    def expire_this_cache
      expire_fragment(%r{/project/#{params[:id]}.*})
      expire_fragment(%r{.*index.*}) 
    end


end
