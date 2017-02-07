class BackupFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_backup_file

  def show
    @revisions = @backup_file.revisions
    @profile = @backup_file.profile
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_backup_file
      @backup_file = BackupFile.joins(:profile).where("backup_files.id = ? AND profiles.user_id = ?", params[:id], current_user.id).first
    end

end
