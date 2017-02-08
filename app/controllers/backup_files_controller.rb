class BackupFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_backup_file, only: [:show]

  def show
    @revisions = @backup_file.revisions
    @profile = @backup_file.profile
  end

  private
    def set_backup_file
      @backup_file = current_user.backup_files.find(params[:id])
    end

end
