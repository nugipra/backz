require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  login_user

  describe "GET #index" do
    clear_backup_files

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "can show how much storage that user used" do
      @profile1 = FactoryGirl.create(:profile, user: @user)
      @file1 = FactoryGirl.create(:backup_file, profile: @profile1, actual_size: 100)
      @file2 = FactoryGirl.create(:backup_file, profile: @profile1, actual_size: 200)

      @profile2 = FactoryGirl.create(:profile, user: @user)
      @file3 = FactoryGirl.create(:backup_file, profile: @profile2, actual_size: 300)
      @file4 = FactoryGirl.create(:backup_file, profile: @profile2, actual_size: 400)
      @folder = FactoryGirl.create(:backup_folder, profile: @profile2)
      @file5 = FactoryGirl.create(:backup_file, profile: @profile2, folder: @folder, actual_size: 500)

      get :index
      expect(assigns(:storage_usage)).to eq(1500)
    end
  end

end
