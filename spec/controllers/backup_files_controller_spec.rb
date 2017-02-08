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

  describe "POST #restore" do
    before(:each) do
      @test_dir = Rails.root.join("spec", "thedir")
      @test_file = @test_dir.join("thefile.txt")
      FileUtils.mkdir_p @test_dir
      profile.backup_paths = @test_file.to_s
      profile.save

      File.open(@test_file, 'wb') { |file| file.write("initial file") }
      profile.run_backup

      File.open(@test_file, 'wb') { |file| file.write("first change") }
      profile.run_backup

      File.open(@test_file, 'wb') { |file| file.write("second change") }
      profile.run_backup
    end

    after(:each) do
      FileUtils.remove_dir @test_dir
    end

    it "assigns the requested backup_file as @backup_file" do
      post :restore, params: {id: profile.backup_files.last.to_param, version: 1}
      expect(assigns(:backup_file)).to eq(profile.backup_files.last)
    end

    it "restores information with whichever backup history that user chose" do
      expect(profile.backup_files.count).to eq(3)
      expect(profile.backup_files[0].version).to eq(1)
      expect(IO.readlines(profile.backup_files[0].storage_path)).to eq(["initial file"])
      expect(profile.backup_files[1].version).to eq(2)
      expect(IO.readlines(profile.backup_files[1].storage_path)).to eq(["first change"])
      expect(profile.backup_files[2].version).to eq(3)
      expect(IO.readlines(profile.backup_files[2].storage_path)).to eq(["second change"])

      # restore newest revision to revision 1
      # content will be restored to "initial file"
      file = profile.backup_files[2]
      post :restore, params: {id: file.to_param, version: 1}
      file.reload
      expect(IO.readlines(file.storage_path)).to eq(["initial file"])
    end
  end

end
