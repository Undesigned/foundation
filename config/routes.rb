Rails.application.routes.draw do
  resources :users, only: [:show] do
    get 'logout', 'import', on: :member
    get 'search', 'edit', on: :collection
    post 'update', on: :collection
  end

  # Omniauth callback
  get '/auth/:provider/callback', to: 'users#auth'
  get 'auth/failure', to: 'users#authfail'

  root to: 'static_pages#home'
end
