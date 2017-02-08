class BackupFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_backup_file

  def show
    @revisions = @backup_file.revisions
    @newest_revision = @backup_file.newest_revision
    @profile = @backup_file.profile
  end

  def restore
    if @backup_file.restore(params[:version])
      @backup_file.reload
      @newest_revision = @backup_file.newest_revision
      redirect_to "/revision_history/#{@newest_revision.id}", notice: 'Backup file was successfully restored.'
    else
      redirect_to "/revision_history/#{@backup_file.id}", notice: 'Backup file was not successfully restored.'
    end
  end

  private
    def set_backup_file
      @backup_file = current_user.backup_files.find(params[:id])
    end

end
