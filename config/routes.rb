Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  resources :profiles do
    member do
      post :run_backup
      get 'browse/:version', to: 'profiles#browse_backup_files', as: :browse_backup_files
    end
  end

  get 'revision_history/:id', to: 'backup_files#show', as: :revision_history
end
