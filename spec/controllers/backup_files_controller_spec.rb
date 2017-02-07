require 'rails_helper'

RSpec.describe BackupFilesController, type: :controller do
  login_user

  let(:profile) {
    FactoryGirl.create(:profile, user: @user)
  }

  let(:backup_file) {
    FactoryGirl.create(:backup_file, profile: profile)
  }

  describe "GET #show" do
    it "assigns the requested backup_file as @backup_file" do
      get :show, params: {id: backup_file.to_param}
      expect(assigns(:backup_file)).to eq(backup_file)
    end
  end

end
