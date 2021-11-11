Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root to: 'pages#home'
  get '/indicadores/12', to: 'samples#twelve', as: :twelve
  get '/indicadores/12', to: 'samples#time', as: :ask_time
  get '/indicadores/02', to: 'samples#two'
  get '/indicadores/30', to: 'samples#thirty'

  authenticate :user, ->(user) { user.admin? } do
    mount Blazer::Engine, at: "blazer"
  end

  resources :samples, only: [:index, :show] do
    collection do
      get :query
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
