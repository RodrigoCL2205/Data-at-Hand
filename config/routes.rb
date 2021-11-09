Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'indicadores/12', to: 'samples#twelve', as: :twelve
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
