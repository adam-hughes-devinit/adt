class ProjectsController < ApplicationController  
before_filter :set_owner, only: [:create, :new]
before_filter :correct_owner?, only: [:edit]
#before_filter :strip_tags_from_description, only: [:create, :update]

  def index
      @search = Project.search do
        fulltext params[:search]
        facet :sector_name 
        with :sector_name, params[:sector_name] if params[:sector_name].present?
        facet :flow_type_name
        with :flow_type_name, params[:flow_type_name] if params[:flow_type_name].present?
        facet :oda_like_name
        with :oda_like_name, params[:oda_like_name] if params[:oda_like_name].present?
        paginate :page => params[:page] || 1, :per_page => params[:max] || 50

      end
      
      @projects = @search.results

    respond_to do |format|
      format.html # index.html.erb
      format.json do
       @projects = Project.all
       render json: @projects 
      end
    end
  end

  # GET /Projects/1
  # GET /Projects/1.json
  def show
    @project = Project.find(params[:id])

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
    deflate_project_values(@project)
    
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
    deflate_project_values(@project)

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

    def deflate_value(value,currency_iso3, yr, donor_iso3)
      require 'open-uri'
      deflator_query = "#{value.to_s}#{currency_iso3}#{yr}#{donor_iso3}"
      deflator_url = "https://oscar.itpir.wm.edu/deflate/api.php?val=#{deflator_query}"
      deflated_amount = open(deflator_url){|io| io.read}
    end

    def deflate_project_values(project)
      if project.donor.present? && project.year.present? 
        
        donor_iso3 = project.donor.iso3 
        year = project.year

        project.transactions.each do |t|
          if t.value.present? and t.value > 0 and t.currency.present?
            deflated_amount = deflate_value(t.value, t.currency.iso3, year, donor_iso3)

            t.usd_defl=deflated_amount.to_f
          else
            t.usd_defl=nil
          end
        end
      end

    end

    def strip_tags_from_description
      @project.description = view_context.strip_tags(@project.description)
      
      if @project.title.blank?
        @project.title = "Unset"
      end

    end

end
