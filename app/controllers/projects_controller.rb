class ProjectsController < ApplicationController  
before_filter :set_owner, only: [:create, :new]
before_filter :correct_owner?, only: [:edit]


  def index

    respond_to do |format|
      format.html do 
        custom_search
        render html: @projects
      end
      format.json do
        custom_search
        render json: @projects
      end
      format.csv do
        params[:max] = Project.all.count
        custom_search
        @ids_for_export = @projects.map { |p| p.id }
        
        if @ids_for_export.length == Project.all.count
        	@csv_data = Cache.find(0).text # this is a chill hack -- id=0 holds all the text.
        else	
        	@csv_data = Cache.where("id in(?)", @ids_for_export ).map{|c| c.text } .join("
")			
				end

				@csv_header = "\uFEFF" + "\"project_id\",\"donor\",\"title\",\"year\",\"year_uncertain\",\"description\",\"sector\",\"sector_comment\",\"crs_sector\",\"status\",\"status_code\",\"flow\",\"tied\",\"tied_code\",\"all recipients\",\"sources\",\"sources_count\",\"funding_agency\",\"implementing_agency\",\"donor_agency\",\"donor_agency_count\",\"recipient_agencies\",\"recipient_agencies_count\",\"verified\",\"verified_code\",\"flow_class\",\"flow_class_code\",\"active\",\"active_code\",\"factiva_sources\",\"amount\",\"currency\",\"deflators_used\",\"exchange_rates_used\",\"usd_defl\",\"start_actual\",\"start_planned\",\"end_actual\",\"end_planned\",\"recipient_count\",\"recipient_condensed\",\"recipient_cow_code\",\"recipient_oecd_code\",\"recipient_oecd_name\",\"recipient_iso3\",\"recipient_iso2\",\"recipient_un_code\",\"recipient_imf_code\",\"is_commercial\",\"is_commercial\",\"debt_uncertain\",\"line_of_credit\",\"is_cofinanced\"
"
        send_data((@csv_header + @csv_data), filename: "AidData_China_#{Time.now.strftime("%y-%m-%d-%H:%M:%S.%L")}.csv")
        
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


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/1/edit
  def edit
    @project = Project.find(params[:id])
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
    @project.destroy

    respond_to do |format|
      format.html { redirect_to Projects_url }
      format.json { head :no_content }
    end
  end

  def media
    @project = Project.find_by_media_id(params[:media_id])
    if current_user && @project.owner == Organization.find_by_name('AidData') && current_user.owner == Organization.find_by_name("AidData")
      render 'edit'
    else
      render 'show'
    end
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
  
  def custom_search(options = {})
    options.reverse_merge! paginate: true

     @facet_labels = ["Sector", "Flow Type", "Flow Class", "Is Commercial", "Active", "Recipient"]
      @facets = facets = [
        {sym: :sector_name, name: "Sector"},
        {sym: :flow_type_name, name: "Flow Type"},
        {sym: :oda_like_name, name: "Flow Class"},
        {sym: :status_name, name:"Status"},
        {sym: :tied_name, name:"Tied/Untied"},
        {sym: :verified_name, name:"Verified/Unverified"},
        {sym: :currency_name, name:"Reported Currency"},
        {sym: :is_commercial_string, name: "Commericial Status"},
        {sym: :active_string, name: "Active/Inactive"},
        {sym: :country_name, name: "Recipient"},
        {sym: :source_type_name, name: "Source Type"},
        {sym: :document_type_name, name: "Document Type"},
        {sym: :origin_name, name: "Organization Origin"},
        {sym: :role_name, name: "Organization Role"},
        {sym: :organization_type_name, name: "Organization Type"},
        {sym: :organization_name, name: "Organization Name"},
        {sym: :owner_name, name: "Record Owner"},
        {sym: :line_of_credit_string, name: "Line of Credit"},
        {sym: :crs_sector, name: "CRS Sector"},
        {sym: :year_uncertain_string, name: "Year Uncertain"},
        {sym: :debt_uncertain_string, name: "Debt Relief Uncertain"},
        {sym: :recipient_iso2, name: ""}
      ].sort! { |a,b| a[:name] <=> b[:name] }
      @search = Project.search do
          fulltext params[:search]
          facets.each do |f|
            facet f[:sym]
            with f[:sym], params[f[:sym]] if params[f[:sym]].present?
          order_by((params[:order_by] ? params[:order_by].to_sym : :title), params[:dir] ? params[:dir].to_sym : :desc )
      end
      
    
      if options[:paginate]==true
        paginate :page => params[:page] || 1, :per_page => params[:max] || 50
      end
    end
    @projects = @search.results
  end


end
