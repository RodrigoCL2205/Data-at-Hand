Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'indicadores/12', to: 'samples#twelve', as: :twelve
  get 'indicadores', to: 'samples#data', as: :ask_time
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
