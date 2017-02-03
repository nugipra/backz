class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [
    :show, :edit, :update, :destroy, :run_backup, :browse_backup_files
  ]

  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = current_user.profiles
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)
    @profile.user_id = current_user.id

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: 'Profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def run_backup
    @profile.run_backup
    redirect_to profiles_url, notice: 'Backups completed sucessfully'
  end

  def browse_backup_files
    if params[:file_id].present?
      @backup_file = @profile.backup_files.find(params[:file_id])
      send_file @backup_file.storage_path
      return
    end

    @parent = @profile.backup_files.find(params[:parent_id]) if params[:parent_id].present?
    @backup_files = @profile.backup_files.where(version: params[:version], parent_id: @parent.try(:id)).order("is_directory desc, filename")
    @backup_version = @profile.backup_files.select("version, max(created_at) as backup_time").group("version").order("version desc")
    @current_backup_version = @backup_version.detect{|b| b.version == params[:version].to_i}

    @total_added_files = @profile.count_files_by_status_and_version("added", params[:version])
    @total_modified_files = @profile.count_files_by_status_and_version("modified", params[:version])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = current_user.profiles.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:name, :backup_paths, :exclusion_paths)
    end
end
