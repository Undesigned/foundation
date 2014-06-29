Rails.application.routes.draw do
  scope "/api" do
    resources :users, only: [:edit] do
      get 'logout', on: :member
    end
  end

  # Omniauth callback
  get '/auth/:provider/callback', to: 'users#auth'
  get 'auth/failure', to: 'users#authfail'

  root to: 'static_pages#home'
end
