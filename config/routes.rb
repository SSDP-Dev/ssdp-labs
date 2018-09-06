Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get  'posts',              to: 'posts#index'
  get  '/posts/new',         to: 'posts#new'
  get  '/posts/edit',        to: 'posts#edit'
  post '/posts/update',      to: 'posts#write'
  get  '/posts/destroy',     to: 'posts#destroy'
end
