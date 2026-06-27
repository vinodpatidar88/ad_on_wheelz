Rails.application.routes.draw do
  devise_for :admin_users
  root to: redirect('/admin')

  # Public flow
  get "c/:qr_token", to: "public_campaigns#show", as: :public_campaign

  # Secure API
  namespace :api do
    namespace :v1 do
      resources :campaigns, param: :qr_token, only: [] do
        member do
          post :select_reward
          post :send_otp
          post :verify_otp
          post :save_profile
        end
      end
    end
  end

  # Admin portal
  namespace :admin do
    root to: "dashboard#index"
    resources :categories
    resources :sub_categories
    resources :campaigns do
      member do
        get :print
      end
    end
    resources :rewards
    resources :user_profiles, only: [:index, :show, :update]
  end
end