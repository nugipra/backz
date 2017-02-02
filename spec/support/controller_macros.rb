module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
  end

  def clear_backup_files
    after(:each) do
      FileUtils.remove_dir BackupFile.base_dir
    end
  end
end