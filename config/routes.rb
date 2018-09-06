Rails.application.routes.draw do
  resources :posts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'wysiwyg', to: 'posts#wysiwyg'
  post 'write', to: 'posts#write'
end
