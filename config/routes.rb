Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root                       to: 'static_pages#index'
  get  'posts',              to: 'posts#index'
  get  '/posts/new',         to: 'posts#new'
  post '/posts/create',      to: 'posts#create'
  get  '/posts/edit',        to: 'posts#edit'
  post '/posts/write',       to: 'posts#write'
  get  '/posts/destroy',     to: 'posts#destroy'
  get  'pages',              to: 'pages#index'
  get  '/pages/new',         to: 'pages#new'
  get  '/pages/edit',        to: 'pages#edit'
  post '/pages/write',       to: 'pages#write'
  post '/pages/create',      to: 'pages#create'
  get  '/pages/destroy',     to: 'pages#destroy'
end
