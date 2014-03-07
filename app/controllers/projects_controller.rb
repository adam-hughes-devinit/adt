class ProjectsController < ApplicationController
  skip_before_filter :signed_in_user, only: [:suggest, :to_english]
  before_filter :set_owner, only: [:create, :new]
  before_filter :correct_owner?, only: [:edit, :destroy]
  before_filter :aiddata_only!, only: [:create]

  # before_filter :lock_editing_except_for_admins, except: [:index, :show, :suggest]

  include SearchHelper
  extend Typeaheadable
  enable_typeahead Project, facets: {active_string: "Active", donor_name: "China"}
  #caches_action :show, cache_path: proc { |c| "projects/#{c.params[:id]}/#{signed_in? ? current_user.id : "not_signed_in"}/}
  #caches_action :index, expires_in: 1.hour, unless: proc { |c| current_user_is_aiddata }

  cache_sweeper :project_sweeper, :only => [:create, :update, :destroy, :save] # app/models/project_sweeper.rb

  def index
    respond_to do |format|

      format.html do

        @full_result_ids = custom_search(paginate: false).map(&:id)
        @projects = custom_search
        @export = Export.new(params[:export])

        render html: @projects
      end

      format.json do
        @projects = custom_search({default_to_official_finance: false})
        render json: @projects
      end

      format.xml do
        @search_results = custom_search({default_to_official_finance: false})
        render xml: Project.wrap_in_iati(@search_results)
      end

      format.csv do

        if params[:page]
          @paginate = true
        else
          @paginate = false
        end

        projects = custom_search(paginate: @paginate, default_to_official_finance: false)

        csv_data = Project.csv_header + "\n"

        projects.each do |p| 
          csv_data << p.csv_text 
          csv_data << "\n"
        end

        send_data csv_data,
          :type => 'text/csv; charset=utf-8; header=present',
          :disposition => "attachment; filename=AidData_China_custom_#{Time.now.strftime("%y-%m-%d-%H:%M:%S-%L")}.csv"
      end
    end
  end


  def show

    @project = Project.unscoped.includes(:participating_organizations, :geopoliticals, :transactions, :contacts, :sources, :resources, :loan_detail).find(params[:id])
    @comment = Comment.new
    @flags = @project.all_flags
    @flag = Flag.new
    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    @loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
      format.xml {render xml: @project}
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
    # @project.sources.build
    @project.resources.build
    @flow_class = @project.flow_class = FlowClass.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/1/edit
  def edit

    @project = Project.unscoped.includes(:participating_organizations, :geopoliticals, :transactions, :contacts, :sources, :resources, :loan_detail).find(params[:id])
    @project.resources.build if @project.resources.empty?

    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    #@loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)

  end

  # POST /Projects
  # POST /Projects.json
  def create
    user_id = params[:project].delete(:user_id)
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to new_project_loan_detail_url(@project.id) }
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
    #need to remove user_id from params
    user_id = params[:project].delete(:user_id)
    #keep track of who changed this project
    Rails.cache.write("last_change/#{params[:id]}", user_id.to_i)
    @project = Project.unscoped.find(params[:id])
    @loan_detail = LoanDetail.where(:project_id => @project.id)

    #for versioning
    @project.save_state

    # Redirects to loan_detail controller
    respond_to do |format|
      if @project.update_attributes(params[:project])

        # recalculate transactions when projects are saved. Otherwise usd_2009 will be wrong.
        @transactions = Transaction.find_all_by_project_id(@project.id)
        @transactions.each do |transaction|
          transaction.save
        end

        format.html { redirect_to edit_project_loan_detail_url(@project.id, @loan_detail[0].id) }
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

    @project = Project.unscoped.find(params[:id])

    # The big problem here was that in @project.destroy, 
    # all the accessory objects were destroyed _first_,
    # so when @project was destroyed (and accessories were saved),
    # the accessories were gone already and accessories was an empty array.
    #
    # To get around this, I'm saving the accessories, deleting everything,
    # then adding the accessories by hand. 
    #
    @accessories = @project.accessories

    @project.destroy


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

  def suggest
    if request.post?
      @project = Project.new(params[:project])
      @project.published = false
      @project.donor = Country.find_by_name("China")
      if @project.save(:validate => false)

        AiddataAdminMailer.delay.contributor_notification(@project, @project, current_user)

        flash[:success] = "Thanks, we will review your project suggestion!"
      else
        flash[:error] = "Sorry -- that operation failed, please try again."
      end
      redirect_to :back
    end
    # suggest.html.haml
  end

  private



  def correct_owner? 
    project_owner = Project.unscoped.find(params[:id]).owner 
    if ( 
        (project_owner.present? && (signed_in? && current_user.owner.present? && (current_user.owner == project_owner)))||
        (current_user_is_aiddata && project_owner.nil?)
       )
       true
    else
      flash[:notice] = "Only #{project_owner.name} can edit this record."
      redirect_to Project.find(params[:id])

    end
  end
  def set_owner
    if signed_in?
      current_user.owner 
    else 
      Organization.find_by_name("AidData")
    end
  end
end
